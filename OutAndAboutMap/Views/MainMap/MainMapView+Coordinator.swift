//
//  MainMapView+Coordinator.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/27/20.
//

import Foundation
import MapKit

extension MainMapView {

    class Coordinator : NSObject, MKMapViewDelegate {
        var parent: MainMapView

        init(_ parent: MainMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay:
            MKOverlay) -> MKOverlayRenderer {

            if let overlay = overlay as? USGSHillshadeWMSTileOverlay {
                let renderer = MKTileOverlayRenderer(overlay: overlay)
                return renderer
            }
            return MKPolylineRenderer()
        }
    }
}
