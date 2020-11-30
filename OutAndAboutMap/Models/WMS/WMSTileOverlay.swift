//
//  WMSTileOverlay.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/29/20.
//

import Foundation
import MapKit

fileprivate let SPHERICAL_MERCATOR_EXTENT = 20037508.34


/**
 * Derived from
 * github/revilosun's [WmsMapKit_Swift](https://github.com/revilosun/WmsMapKit_Swift)
 */
class WMSTileOverlay : MKTileOverlay {

    private let fm = FileManager.default

    let format: String

    let cacheURL: URL
    let baseSrcURL: URL

    private var cacheHits = 0
    private var cacheMisses = 0

    init(
        serverBase: String,
        request: String,
        layers: String,
        styles: String,
        crs: String,
        tileSize: Int,
        format: String,
        cacheName: String,
        maxZoom: Int,
        minZoom: Int = 0
    ) {

        var components = URLComponents(string: serverBase)!
        components.queryItems = [
            .init(name: "service", value: "WMS"),
            .init(name: "version", value: "1.3.0"),
            .init(name: "request", value: request),
            .init(name: "layers", value: layers),
            .init(name: "styles", value: styles),
            .init(name: "crs", value: crs),
            .init(name: "width", value: String(tileSize)),
            .init(name: "height", value: String(tileSize)),
            .init(name: "format", value: format)
        ]
        self.baseSrcURL = components.url!
        self.cacheURL = WMSTileOverlay.ensureCacheURL(cacheName: cacheName)
        self.format = format

        super.init(urlTemplate: nil)

        self.minimumZ = minZoom
        self.maximumZ = maxZoom
        self.tileSize = CGSize(width: tileSize, height: tileSize)
    }

    override func loadTile(
        at path: MKTileOverlayPath,
        result: @escaping (Data?, Error?) -> Void
    ) {

        let bbox = generateBbox(from: path)

        let cacheFileURL = self.cacheURL.appendingPathComponent(bbox)

        if self.fm.fileExists(atPath: cacheFileURL.path) {
            do {
                let data = try self.loadFromCache(url: cacheFileURL)
                result(data, nil)
                self.cacheHits += 1
            } catch {
                result(nil, WMSError.cacheIO(bbox: bbox, inner: error))
            }
        } else {
            self.cacheMisses += 1
            let request = URL(string: "\(self.baseSrcURL)&\(bbox)")!
            let downloadTask = URLSession.shared.dataTask(with: request) {
                (data, response, error)
                in

                if let err = self.isError(
                    bbox: bbox, data: data, response: response, err: error
                ) {
                    result(nil, err)
                } else {
                    do {
                        try data!.write(to: cacheFileURL)
                        result(data, nil)
                    } catch {
                        result(nil, WMSError.cacheIO(bbox: bbox, inner: error))
                    }
                }
            }

            downloadTask.resume()
        }
    }

    private func loadFromCache(url: URL) throws -> Data {
        return try Data(contentsOf: url, options: .alwaysMapped)
    }

    private func isError(
        bbox: String, data: Data?, response: URLResponse?, err: Error?
    ) -> WMSError? {
        let mimeType = response?.mimeType?.lowercased()
        if err != nil {
            return WMSError.errResponse(bbox: bbox, inner: err!)
        } else if mimeType?.hasSuffix("xml") == true {
            if let responseData = String(data: data!, encoding: .utf8) {
                return WMSError.xmlResponse(bbox: bbox, err: responseData)
            } else {
                return WMSError.unknown(bbox: bbox, message: "XML but no body")
            }
        } else if mimeType != self.format {
            return WMSError.unknown(
                bbox: bbox, message: "Bad mime \(String(describing: mimeType))"
            )
        }
        return nil
    }

    private func generateBbox(from path: MKTileOverlayPath) -> String {
        let z = path.z
        let left = normalizeX(column: path.x, zoom: z)
        let right = normalizeX(column: path.x+1, zoom: z)
        let bottom = normalizeY(row: path.y+1, zoom: z)
        let top = normalizeY(row: path.y, zoom: z)

        return "bbox=\(left),\(bottom),\(right),\(top)"
    }

    private func normalizeX(column: Int, zoom: Int) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return (x / pow(2.0, z) * 2 - 1) * SPHERICAL_MERCATOR_EXTENT

    }

    private func normalizeY(row: Int, zoom: Int) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = .pi - 2.0 * .pi * y / pow(2.0, z)
        let lat = 180.0 / .pi * atan(0.5 * (exp(n) - exp(-n)))

        return log(tan((90 + lat) * .pi / 360))
            / .pi * SPHERICAL_MERCATOR_EXTENT
    }

    private static func ensureCacheURL(cacheName: String) -> URL {
        let fm = FileManager.default
        let cache = try! fm.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
        ).appendingPathComponent(cacheName, isDirectory: true)

        try! fm.createDirectory(at: cache, withIntermediateDirectories: true)

        return cache
    }
}
