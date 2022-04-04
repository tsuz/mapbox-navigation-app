//
//  Place.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/24.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id = UUID().uuidString
    var place: CLPlacemark
}
