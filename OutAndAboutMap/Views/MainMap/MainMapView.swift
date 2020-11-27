//
//  MainMapView.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/26/20.
//

import SwiftUI
import MapKit

struct MainMapView: View {
    @ObservedObject
    var model = MainMapModel()

    var body: some View {
        Map(
            coordinateRegion: $model.region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $model.trackingMode
        )
    }
}

#if DEBUG
struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}
#endif
