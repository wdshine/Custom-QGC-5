qt_add_plugin(QGCLocation
    STATIC
    CLASS_NAME QGeoServiceProviderFactoryQGC
    OUTPUT_TARGETS QGCLocation_targets
    Providers/BingMapProvider.cpp
    Providers/BingMapProvider.h
    Providers/ElevationMapProvider.cpp
    Providers/ElevationMapProvider.h
    Providers/EsriMapProvider.cpp
    Providers/EsriMapProvider.h
    Providers/GenericMapProvider.cpp
    Providers/GenericMapProvider.h
    Providers/GoogleMapProvider.cpp
    Providers/GoogleMapProvider.h
    Providers/MapboxMapProvider.cpp
    Providers/MapboxMapProvider.h
    Providers/MapProvider.cpp
    Providers/MapProvider.h
    QMLControl/QGCMapEngineManager.cc
    QMLControl/QGCMapEngineManager.h
    QGCCachedTileSet.cpp
    QGCCachedTileSet.h
    QGCCacheTile.h
    QGCMapEngine.cpp
    QGCMapEngine.h
    QGCMapTasks.h
    QGCMapUrlEngine.cpp
    QGCMapUrlEngine.h
    QGCTile.h
    QGCTileCacheWorker.cpp
    QGCTileCacheWorker.h
    QGCTileSet.h
    QGeoFileTileCacheQGC.cpp
    QGeoFileTileCacheQGC.h
    QGeoMapReplyQGC.cpp
    QGeoMapReplyQGC.h
    QGeoServiceProviderPluginQGC.cpp
    QGeoServiceProviderPluginQGC.h
    QGeoTiledMappingManagerEngineQGC.cpp
    QGeoTiledMappingManagerEngineQGC.h
    QGeoTiledMapQGC.cpp
    QGeoTiledMapQGC.h
    QGeoTileFetcherQGC.cpp
    QGeoTileFetcherQGC.h
)

if(IOS)
    target_compile_definitions(QGCLocation PRIVATE QGC_NO_GOOGLE_MAPS)
endif()

target_link_libraries(QGCLocation
    PRIVATE
        Qt6::Positioning
        Qt6::Sql
    PUBLIC
        Qt6::Core
        Qt6::Location
        Qt6::LocationPrivate
        Qt6::Network
)

target_include_directories(QGCLocation
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/..
        ${CMAKE_CURRENT_SOURCE_DIR}/../FactSystem
        ${CMAKE_CURRENT_SOURCE_DIR}/../QmlControls
        ${CMAKE_CURRENT_SOURCE_DIR}/../Terrain
        ${CMAKE_CURRENT_SOURCE_DIR}/../Terrain/Providers
        ${CMAKE_CURRENT_SOURCE_DIR}/../Settings
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities/FileSystem
        Providers
        QMLControl
)

set_source_files_properties(QMLControl/OfflineMapEditor.qml PROPERTIES QT_RESOURCE_ALIAS OfflineMapEditor.qml)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE QGCLocation)

# qt_add_qml_module(QGCLocation
#     URI QGroundControl.QGCLocation
#     VERSION 1.0
#     QML_FILES
#         QMLControl/OfflineMapEditor.qml
#     OUTPUT_TARGETS QGCLocation_targets
#     IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
#     IMPORTS
#       QtQuick
#       QtQuick.Controls
#       QtQuick.Layouts
#       QtQuick.Dialogs
#       QtQuick.Controls
#       QtLocation
#       QtPositioning

#       QGroundControl
#       QGroundControl.Controls
#       QGroundControl.ScreenTools
#       QGroundControl.Palette
#       QGroundControl.FlightMap
#       QGroundControl.QGCMapEngineManager
#       QGroundControl.FactSystem
#       QGroundControl.FactControls
# )
