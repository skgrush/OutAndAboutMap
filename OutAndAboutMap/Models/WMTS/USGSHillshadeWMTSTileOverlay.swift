//
//  USGSHillshadeWMTSTileOverlay.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/27/20.
//

import Foundation
import MapKit

/**
 * *Not working* for some reason :(
 */
final class USGSHillshadeWMTSTileOverlay : MKTileOverlay {

    private static let MERCATOR_CONSTANT = 20037508.34

    private static let LOWER_BOUND_X = -2.00375070738129E7
    private static let LOWER_BOUND_Y = -2.671293453885978E7
    private static let UPPER_BOUND_X = 2.0037750667261E7
    private static let UPPER_BOUND_Y = 1.880706619151872E7
    private static let BOUND_WIDTH = UPPER_BOUND_X - LOWER_BOUND_X
    private static let BOUND_HEIGHT = UPPER_BOUND_Y - LOWER_BOUND_Y

//    private static let BOUNDING_RECT = MKMapRect(
//        x: USGSHillshadeWMTSTileOverlay.LOWER_BOUND_X,
//        y: USGSHillshadeWMTSTileOverlay.LOWER_BOUND_Y,
//        width: USGSHillshadeWMTSTileOverlay.BOUND_WIDTH,
//        height: USGSHillshadeWMTSTileOverlay.BOUND_HEIGHT
//    )
    private static let TILE_SIZE = CGSize(width: 256, height: 256)

    private static let TILES_X = MKMapSize.world.width / Double(TILE_SIZE.width)
    private static let BASE_ZOOM = log2(TILES_X)

    let baseURL = URL(string: "https://basemap.nationalmap.gov/arcgis/rest/services/USGSShadedReliefOnly/MapServer/WMTS/tile/1.0.0/USGSShadedReliefOnly")!

    let style = "default"
    let tileMatrixSet = "default028mm"

//    override var boundingMapRect: MKMapRect {
//        Self.BOUNDING_RECT
//    }

    init() {
        super.init(urlTemplate: nil)
        self.tileSize = Self.TILE_SIZE
        self.minimumZ = 0
        self.maximumZ = 23
//        self.canReplaceMapContent = true
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let x = normalizeX(column: path.x, zoom: path.z)
        let y = normalizeY(row: path.y, zoom: path.z)
//        let z = normalizeZ(zoom: path.z)
        let z = path.z

        return baseURL
            .appendingPathComponent(style)
            .appendingPathComponent(tileMatrixSet)
            .appendingPathComponent(String(z))
            .appendingPathComponent(String(x))
            .appendingPathComponent(String(y))
    }

//    private func normalizeZ(zoom: Double) -> Int {
//        let normalizedZoom = Int(Self.BASE_ZOOM + round(log2(Double(zoom))))
//        return max(self.minZoom, normalizedZoom)
//    }

    /**
     * Convert a MKTileOverlay column to a mercator X.
     */
    private func normalizeX(column: Int, zoom: Int) -> Double {
        (Double(column) / pow(2, Double(zoom)) * 2 - 1) * Self.MERCATOR_CONSTANT
    }
//    private func normalizeX(column: Int, zoom: Int) -> Double {
//        let x = Double(column)
//        let z = Double(zoom)
//        let lon = x / pow(2.0, z) * 360.0 - 180
//
//        return lon * 20037508.34 / 180
//    }

    /**
     * Convert a MKTileOverlay row to a mercator Y.
     */
    private func normalizeY(row: Int, zoom: Int) -> Double {
        let latitude = .pi - 2.0 * .pi * Double(row) / pow(2.0, Double(zoom))
        return log(tan((90 + latitude) * .pi / 360)) / .pi
            * Self.MERCATOR_CONSTANT
    }

//    private func normalizeY(row: Int, zoom: Int) -> Double {
//        let y = Double(row)
//        let z = Double(zoom)
//        let n = .pi - 2.0 * .pi * y / pow(2.0, z)
//        let lat = 180.0 / .pi * atan(0.5 * (exp(n) - exp(-n)))
//
//        var normY = log(tan((90 + lat) * .pi / 360)) / (.pi / 180)
//        normY *= 20037508.34 / 180
//        return normY
//    }

}
