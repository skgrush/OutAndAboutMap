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

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        context.coordinator.didLoad(mapView: mapView)

        mapView.showsUserLocation = true

        mapView.region = model.region
        mapView.setUserTrackingMode(.followWithHeading, animated: true)

        mapView.translatesAutoresizingMaskIntoConstraints = false

        let longTapGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longTap))
        mapView.addGestureRecognizer(longTapGesture)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.didUpdate(mapView: mapView)
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
