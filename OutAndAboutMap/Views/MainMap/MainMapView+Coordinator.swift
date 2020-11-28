//
//  MainMapView+Coordinator.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/27/20.
//

import Foundation
import MapKit

extension MainMapView {

    class Coordinator : NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parentView: MainMapView
        var locManager: CLLocationManager
        var mapView: MKMapView?

        init(_ view: MainMapView) {
            self.parentView = view

            self.locManager = CLLocationManager()
            super.init()
            self.locManager.delegate = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay:
            MKOverlay) -> MKOverlayRenderer {

            if let overlay = overlay as? USGSHillshadeWMSTileOverlay {
                let renderer = MKTileOverlayRenderer(overlay: overlay)
                return renderer
            }
            return MKPolylineRenderer()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? MKPointAnnotation {
                let reuseId = "pin"
                var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

                if pinView == nil {
                    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                    pinView!.canShowCallout = true
                    pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
                    pinView!.pinTintColor = UIColor.black
                }
                else {
                    pinView!.annotation = annotation
                }

                let location = annotation.coordinate

                if mapView.isUserLocationVisible {
                    let dist = mapView.userLocation.location!.distance(
                        from: CLLocation(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    )
                    annotation.title = "\(dist) m"
                }

                return pinView
            }

            return nil
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parentView.model.region = mapView.region
        }

        func didLoad(mapView: MKMapView) {
            self.mapView = mapView
            mapView.addOverlay(parentView.model.tileOverlay)
        }

        func didUpdate(mapView: MKMapView) {
            var btn = mapView.subviews.first { $0 is MKUserTrackingButton }
            if btn == nil {
                btn = setupUserTracking(mapView: mapView)
                mapView.addSubview(btn!)
            }
            btn!.center = CGPoint(x: 50, y: 50)
        }

        func locationManagerDidChangeAuthorization(
            _ manager: CLLocationManager
        ) {
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }
        }

        @objc func longTap(sender: UIGestureRecognizer) {
            if sender.state == .began {
                let locationInView = sender.location(in: mapView!)
                let locationOnMap = mapView!.convert(locationInView, toCoordinateFrom: mapView!)
                addAnnotation(location: locationOnMap)
            }
        }

        func addAnnotation(location: CLLocationCoordinate2D) {

            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.subtitle = "\(location.latitude)  \(location.longitude)"

            if mapView!.isUserLocationVisible {
                let dist = mapView!.userLocation.location!.distance(
                    from: CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                )
                annotation.title = "\(dist) m"
            } else {
                annotation.title = "Point"
            }

            self.mapView!.addAnnotation(annotation)
        }

        private func setupUserTracking(mapView: MKMapView) -> some UIView {
            let btn = MKUserTrackingButton(mapView: mapView)
            btn.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
            btn.layer.borderColor = UIColor.white.cgColor
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 5
            btn.translatesAutoresizingMaskIntoConstraints = false

            return btn
        }
    }
}
