# QGroundControl

## Video Streaming

QGroundControl implements an UDP RTP and RSTP video streaming receiver in its Main Flight Display using GStreamer.
Current suggested version of GStreamer is **1.22.12** - other versions of GStreamer may break the build as some dependent libraries may change.
To build video streaming support, you will need to install the GStreamer development packages for the desired target platform.

If you do have the proper GStreamer development libraries installed where QGC looks for it, the QGC build system will automatically use it and build video streaming support. If you would like to disable GStreamer video streaming support, set the **QGC_ENABLE_GST_VIDEOSTREAMING** CMake option to **OFF**.

### Gstreamer logs

For cases, when it is need to have more control over gstreamer logging than is availabe via QGroundControl's UI, it is possible to configure gstreamer logging via environment variables. Please see https://developer.gnome.org/gstreamer/stable/gst-running.html for details.

### UDP Pipeline

For the time being, the RTP UDP pipeline is somewhat hardcoded, using h.264 or h.265. It's best to use a camera capable of hardware encoding either h.264 (such as the Logitech C920) or h.265. On the sender end, for RTP (UDP Streaming) you would run something like this:

h.264

```
gst-launch-1.0 uvch264src initial-bitrate=1000000 average-bitrate=1000000 iframe-period=1000 device=/dev/video0 name=src auto-start=true src.vidsrc ! video/x-h264,width=1920,height=1080,framerate=24/1 ! h264parse ! rtph264pay ! udpsink host=xxx.xxx.xxx.xxx port=5600
```

h.265

```
ffmpeg -f v4l2 -i /dev/video1 -pix_fmt yuv420p -c:v libx265 -preset ultrafast -x265-params crf=23 -strict experimental -f rtp udp://xxx.xxx.xxx.xxx:5600
```

Where xxx.xxx.xxx.xxx is the IP address where QGC is running.

To test using a test source on localhost, you can run this command:

```
gst-launch-1.0 videotestsrc pattern=ball ! video/x-raw,width=640,height=480 ! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=5600
```

Or this one:

```
gst-launch-1.0 videotestsrc ! video/x-raw,width=640,height=480 ! videoconvert ! x264enc ! rtph264pay ! udpsink host=127.0.0.1 port=5600
```

On the receiving end, if you want to test it from the command line, you can use something like:

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' ! rtpjitterbuffer ! rtph264depay ! h264parse ! avdec_h264 ! autovideosink fps-update-interval=1000 sync=false
```

Or this one:

```
gst-launch-1.0 udpsrc port=5600 ! application/x-rtp ! rtpjitterbuffer ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink
```

Or this one, note that removing rtpjitterbuffer would reduce video latency as low latency mode is doing:

```
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' ! rtpjitterbuffer ! parsebin ! decodebin ! autovideosink fps-update-interval=1000 sync=false
```

### Additional Protocols

QGC also supports RTSP, TCP-MPEG2 and MPEG-TS pipelines.

## Setup

### Linux

For a quick setup, use the setup tool provided at qgroundcontrol/tools/setup/install-dependencies-debian.sh.

Alternatively for a manual approach you can use apt-get to install GStreamer 1.0:

```
list=$(apt-cache --names-only search ^gstreamer1.0-* | awk '{ print $1 }' | sed -e /-doc/d | grep -v gstreamer1.0-hybris)
```

```
sudo apt-get install $list
```

```
sudo apt-get install libgstreamer-plugins-base1.0-dev
sudo apt-get install libgstreamer-plugins-bad1.0-dev
```

The build system is setup to use pkgconfig and it will find the necessary headers and libraries automatically.

### Mac OS

Download the gstreamer framework from here: http://gstreamer.freedesktop.org/data/pkg/osx. Supported version is 1.22.12.

You need two packages:

- [gstreamer-1.0-devel-1.22.12-x86_64.pkg](https://gstreamer.freedesktop.org/data/pkg/osx/1.22.12/gstreamer-1.0-devel-1.22.12-universal.pkg)
- [gstreamer-1.0-1.22.12-x86_64.pkg](https://gstreamer.freedesktop.org/data/pkg/osx/1.22.12/gstreamer-1.0-1.22.12-universal.pkg)

The installer places them under /Library/Frameworks/GStreamer.framework, which is where the QGC build system will look for it. That's all that is needed. When you build QGC and it finds the gstreamer framework, it automatically builds video streaming support.

:point_right: To run gstreamer commands from the command line, you can add the path to find them (either in ~/.profile or ~/.bashrc):

```
export PATH=$PATH:/Library/Frameworks/GStreamer.framework/Commands
```

### iOS

Download the gstreamer framework from here: [gstreamer-1.0-devel-1.22.12-ios-universal.pkg](https://gstreamer.freedesktop.org/data/pkg/ios/1.22.12/gstreamer-1.0-devel-1.22.12-ios-universal.pkg)

The installer places them under ~/Library/Developer/GStreamer/iPhone.sdk/GStreamer.framework, which is where the QGC build system will look for it. That's all that is needed. When you build QGC and it finds the gstreamer framework, it automatically builds video streaming support.

### Android

An appropriate version of GStreamer will be automatically downloaded as part of the CMake configure step.

#### Important Note for Windows Users

During the build process for Android on Windows, to ensure support for UNIX-like symbolic links when not using elevated privileges, **Developer Mode** must be enabled. Without enabling Developer Mode, you may encounter linking issues with the automatically downloaded prebuilt version of GStreamer.

To enable Developer Mode:

1. Open the **Settings** app on Windows.
2. Go to **System** > **For developers**.
3. Enable **Developer Mode** by toggling the switch.

### Windows

Download the gstreamer framework from here: http://gstreamer.freedesktop.org/data/pkg/windows. Supported version is 1.22.12. QGC may work with newer version, but it is untested.

You need two packages:

- [gstreamer-1.0-devel-msvc-x86_64-1.22.12.msi](https://gstreamer.freedesktop.org/data/pkg/windows/1.22.12/msvc/gstreamer-1.0-devel-msvc-x86_64-1.22.12.msi)
- [gstreamer-1.0-msvc-x86_64-1.22.12.msi](https://gstreamer.freedesktop.org/data/pkg/windows/1.22.12/msvc/gstreamer-1.0-msvc-x86_64-1.22.12.msi)

Make sure you select "Complete" installation instead of "Typical" installation during the install process.

The following environment variables can be used to configure the GStreamer installation path:
GSTREAMER_1_0_ROOT_X86_64
GSTREAMER_1_0_ROOT_MSVC_X86_64
GSTREAMER_1_0_ROOT_MINGW_X86_64

### Gstreamer Config

When running QGC, you can provide the command line options to configure GStreamer:
--gst-version                   "Print the GStreamer version"
--gst-fatal-warnings            "Make all warnings fatal"
--gst-debug-help                "Print available debug categories and exit"
--gst-debug-level               "Default debug level from 1 (only error) to 9 (anything) or 0 for no output"
--gst-debug                     "Comma-separated list of category_name:level pairs to set specific levels for the individual categories. Example: GST_AUTOPLUG:5,GST_ELEMENT_*:3"
--gst-debug-no-color            "Disable colored debugging output"
--gst-debug-color-mode          "Changes coloring mode of the debug log. Possible modes: off, on, disable, auto, unix"
--gst-debug-disable             "Disable debugging"
--gst-plugin-path               "Colon-separated paths containing plugins"
--gst-plugin-load               "Comma-separated list of plugins to preload in addition to the list stored in environment variable GST_PLUGIN_PATH"
--gst-disable-segtrap           "Disable trapping of segmentation faults during plugin loading"
--gst-disable-registry-update   "Disable updating the registry"
--gst-disable-registry-fork     "Disable spawning a helper process while scanning the registry"
