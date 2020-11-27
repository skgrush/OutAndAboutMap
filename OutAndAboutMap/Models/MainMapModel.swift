//
//  MainMapModel.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/26/20.
//

import Foundation
import MapKit
import SwiftUI

final class MainMapModel : ObservableObject {

    private static let defaultLoc = CLLocationCoordinate2DMake(
        38.60122892329974,
        -90.4470831099787
    )
    private static let defaultSpanDegrees: CLLocationDegrees = 2

    @Published
    var region = MKCoordinateRegion(
        center: defaultLoc,
        span: .init(
            latitudeDelta: defaultSpanDegrees,
            longitudeDelta: defaultSpanDegrees
        )
    )

    @Published
    var trackingMode = MapUserTrackingMode.none
}
