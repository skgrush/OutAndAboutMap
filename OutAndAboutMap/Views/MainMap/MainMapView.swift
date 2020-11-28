//
//  MainMapView.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/26/20.
//

import SwiftUI
import MapKit

struct MainMapView : UIViewRepresentable {

    @ObservedObject
    var model = MainMapModel()

    @State
    var overlayLoaded = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        mapView.translatesAutoresizingMaskIntoConstraints = false

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if !overlayLoaded {
            mapView.addOverlay(model.tileOverlay)
        }

        mapView.translatesAutoresizingMaskIntoConstraints = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}
#endif
