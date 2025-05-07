/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controllers
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

// To implement a custom overlay copy this code to your own control in your custom code source. Then override the
// FlyViewCustomLayer.qml resource with your own qml. See the custom example and documentation for details.
Item {
    id: _root

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

    // since this file is a placeholder for the custom layer in a standard build, we will just pass through the parent insets
    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    parentToolInsets.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset
    }


    // 新增飞机状态显示
    Item {
        id: quadcopterStatus

        // 使用 QGCToolInsets 来限制位置和大小
        property var parentToolInsets: _toolInsets  // 获取父控件的内边距信息

        // 飞行器状态
        property string status: "normal" // 可设置为 "inactive", "normal", "warning", "error"

        // 控件的位置和尺寸
        width: 130
        height: 130
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: parentToolInsets.leftEdgeBottomInset + 10  // 以内边距限制小组件位置

        // 半透明的黑色背景矩形
        Rectangle {
            id: background
            width: parent.width
            height: parent.height
            color: "black"
            opacity: 0.7
            radius: 5
        }

        // 无人机状态显示区域
        Item {
            id: droneItem
            width: parent.width
            height: parent.height

            // 中心机身（长方形）
            Rectangle {
                id: body
                width: 40
                height: 40
                color: getStatusColor()  // 根据状态设置颜色
                anchors.centerIn: parent
            }

            // 四个电机（使用 Rectangle 替代 Ellipse）
            Rectangle {
                id: motor1
                width: 20
                height: 20
                radius: 10 // 设置圆角来模拟圆形
                color: getStatusColor()  // 根据状态设置颜色
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 16
            }

            Rectangle {
                id: motor2
                width: 20
                height: 20
                radius: 10 // 设置圆角来模拟圆形
                color: getStatusColor()  // 根据状态设置颜色
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 16
            }

            Rectangle {
                id: motor3
                width: 20
                height: 20
                radius: 10 // 设置圆角来模拟圆形
                color: getStatusColor()  // 根据状态设置颜色
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 16
            }

            Rectangle {
                id: motor4
                width: 20
                height: 20
                radius: 10 // 设置圆角来模拟圆形
                color: getStatusColor()  // 根据状态设置颜色
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 16
            }

            // 连接机身和电机的线条
            // 连接机身和电机1
            Rectangle {
                id: line1
                width: 2
                color: "white"
                readonly property real bodyCenterX: body.x + body.width/2
                readonly property real bodyCenterY: body.y + body.height/2
                readonly property real motorCenterX: motor1.x + motor1.width/2
                readonly property real motorCenterY: motor1.y + motor1.height/2

                height: Math.sqrt(Math.pow(motorCenterX - bodyCenterX, 2) +
                                 Math.pow(motorCenterY - bodyCenterY, 2))
                rotation: Math.atan2(motorCenterY - bodyCenterY,
                                    motorCenterX - bodyCenterX) * 180 / Math.PI
                x: bodyCenterX - width/2
                y: bodyCenterY
                transformOrigin: Item.Top
            }

            // 连接机身和电机2
            Rectangle {
                id: line2
                width: 2
                color: "white"
                readonly property real bodyCenterX: body.x + body.width/2
                readonly property real bodyCenterY: body.y + body.height/2
                readonly property real motorCenterX: motor2.x + motor2.width/2
                readonly property real motorCenterY: motor2.y + motor2.height/2

                height: Math.sqrt(Math.pow(motorCenterX - bodyCenterX, 2) +
                                 Math.pow(motorCenterY - bodyCenterY, 2))
                rotation: Math.atan2(motorCenterY - bodyCenterY,
                                    motorCenterX - bodyCenterX) * 180 / Math.PI
                x: bodyCenterX - width/2
                y: bodyCenterY
                transformOrigin: Item.Top
            }

            // 连接机身和电机3
            Rectangle {
                id: line3
                width: 2
                color: "white"
                readonly property real bodyCenterX: body.x + body.width/2
                readonly property real bodyCenterY: body.y + body.height/2
                readonly property real motorCenterX: motor3.x + motor3.width/2
                readonly property real motorCenterY: motor3.y + motor3.height/2

                height: Math.sqrt(Math.pow(motorCenterX - bodyCenterX, 2) +
                                 Math.pow(motorCenterY - bodyCenterY, 2))
                rotation: Math.atan2(motorCenterY - bodyCenterY,
                                    motorCenterX - bodyCenterX) * 180 / Math.PI
                x: bodyCenterX - width/2
                y: bodyCenterY
                transformOrigin: Item.Top
            }

            // 连接机身和电机4
            Rectangle {
                id: line4
                width: 2
                color: "white"
                readonly property real bodyCenterX: body.x + body.width/2
                readonly property real bodyCenterY: body.y + body.height/2
                readonly property real motorCenterX: motor4.x + motor4.width/2
                readonly property real motorCenterY: motor4.y + motor4.height/2

                height: Math.sqrt(Math.pow(motorCenterX - bodyCenterX, 2) +
                                 Math.pow(motorCenterY - bodyCenterY, 2))
                rotation: Math.atan2(motorCenterY - bodyCenterY,
                                    motorCenterX - bodyCenterX) * 180 / Math.PI
                x: bodyCenterX - width/2
                y: bodyCenterY
                transformOrigin: Item.Top
            }
        }

        // 根据状态返回对应的颜色
        function getStatusColor() {
            if (status === "inactive") {
                return "rgba(255, 255, 255, 0.5)"; // 透明白色
            } else if (status === "normal") {
                return "green"; // 正常为绿色
            } else if (status === "warning") {
                return "yellow"; // 警告为黄色
            } else if (status === "error") {
                return "red"; // 故障为红色
            }
            return "transparent"; // 默认透明
        }

        // 更新状态时改变颜色
        Component.onCompleted: {
            console.log("Quadcopter component initialized with status: " + status);
        }
    }





}


