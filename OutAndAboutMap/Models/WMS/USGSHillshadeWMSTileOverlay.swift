//
//  USGSHillshadeWMSTileOverlay.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/27/20.
//

import Foundation
import MapKit

enum WMSError : Error {
    case cacheLoad(bbox: String, inner: Error)

}

/**
 * Pull Hillshade imagery from National Map's data source!
 *
 * [Data source](https://catalog.data.gov/dataset/usgs-hill-shade-base-map-service-from-the-national-map/resource/15d2ac1a-022c-4a80-925c-a8b3b8db537d)
 *
 * Derived from
 * github/revilosun's [WmsMapKit_Swift](https://github.com/revilosun/WmsMapKit_Swift)
 */
final class USGSHillshadeWMSTileOverlay : MKTileOverlay {

    private static let MERCATOR_CONSTANT = 20037508.34

    private static let LOWER_BOUND_X = -2.00375070738129E7
    private static let LOWER_BOUND_Y = -2.671293453885978E7
    private static let UPPER_BOUND_X = 2.0037750667261E7
    private static let UPPER_BOUND_Y = 1.880706619151872E7
    private static let BOUND_WIDTH = UPPER_BOUND_X - LOWER_BOUND_X
    private static let BOUND_HEIGHT = UPPER_BOUND_Y - LOWER_BOUND_Y

    private static let TILE_SIZE = 256

    private static let TILES_X = MKMapSize.world.width / Double(TILE_SIZE)
    private static let BASE_ZOOM = log2(TILES_X)
    private static let STYLE = "default"
    private static let FORMAT = "image/png"
    private static let CRS = "EPSG:3857"
    private static let CACHE_DIR = "tile-cache"

    let baseSrcURL: URL

    private let fm = FileManager.default
    private let cacheURL: URL

    init() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "basemap.nationalmap.gov"
        components.port = 443
        components.path = "/arcgis/services/USGSShadedReliefOnly/MapServer/WmsServer"
        components.queryItems = [
            .init(name: "service", value: "WMS"),
            .init(name: "version", value: "1.3.0"),
            .init(name: "request", value: "GetMap"),
            .init(name: "layers", value: "0"),
            .init(name: "styles", value: Self.STYLE),
            .init(name: "crs", value: Self.CRS),
            .init(name: "width", value: String(Self.TILE_SIZE)),
            .init(name: "height", value: String(Self.TILE_SIZE)),
            .init(name: "format", value: Self.FORMAT)
        ]

        self.baseSrcURL = components.url!
        self.cacheURL = Self.ensureCacheURL()

        super.init(urlTemplate: nil)

        self.maximumZ = 17
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let bbox = generateBbox(from: path)
        return baseSrcURL.appendingPathComponent(bbox)
    }

    private func generateBbox(from path: MKTileOverlayPath) -> String {
        let left = normalizeX(column: path.x, zoom: path.z)
        let right = normalizeX(column: path.x+1, zoom: path.z)
        let bottom = normalizeY(row: path.y+1, zoom: path.z)
        let top = normalizeY(row: path.y, zoom: path.z)

        return "bbox=\(left),\(bottom),\(right),\(top)"
    }

    private func normalizeX(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return (x / pow(2.0, z) * 2 - 1) * Self.MERCATOR_CONSTANT

    }

    private func normalizeY(row: Int, zoom: Int) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = .pi - 2.0 * .pi * y / pow(2.0, z)
        let lat = 180.0 / .pi * atan(0.5 * (exp(n) - exp(-n)))

        return log(tan((90 + lat) * .pi / 360)) / .pi * Self.MERCATOR_CONSTANT
    }

    private static func ensureCacheURL() -> URL {
        let fm = FileManager.default
        let cache = fm
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(CACHE_DIR, isDirectory: true)

        try! fm.createDirectory(at: cache, withIntermediateDirectories: true)

        return cache
    }


}
