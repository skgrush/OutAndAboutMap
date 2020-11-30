//
//  USGSHillshadeWMSTileOverlay.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/27/20.
//

import Foundation
import MapKit

enum WMSError : Error {
    case cacheIO(bbox: String, inner: Error)
    case xmlResponse(bbox: String, err: String)
    case errResponse(bbox: String, inner: Error)
    case unknown(bbox: String, message: String)
}

/**
 * Pull Hillshade imagery from National Map's data source!
 *
 * [Data source](https://catalog.data.gov/dataset/usgs-hill-shade-base-map-service-from-the-national-map/resource/15d2ac1a-022c-4a80-925c-a8b3b8db537d)
 *
 * Derived from
 * github/revilosun's [WmsMapKit_Swift](https://github.com/revilosun/WmsMapKit_Swift)
 */
final class USGSHillshadeWMSTileOverlay : WMSTileOverlay {
    init() {
        let serverBase =
            "https://basemap.nationalmap.gov:443" +
            "/arcgis/services/USGSShadedReliefOnly/MapServer/WmsServer"

        super.init(
            serverBase: serverBase,
            request: "GetMap",
            layers: "0",
            styles: "default",
            crs: "EPSG:102100",
            tileSize: 4096,
            format: "image/png",
            cacheName: "hillshade-wms-tile-cache",
            maxZoom: 12
        )
    }
}
