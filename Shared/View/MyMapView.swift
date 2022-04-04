//
//  MyMapView.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/22.
//

import Foundation
import UIKit
import MapboxMaps
import MapKit
import Polyline
import SwiftUI

public enum MapStyle: String {
    case dem = "mapbox://styles/mapbox-map-design/ckhqrf2tz0dt119ny6azh975y"
    case satellite = "mapbox://styles/mapbox/satellite-v9"
    case threeDimensionBuildings = "mapbox://styles/takutosuzukimapbox/cl11tp1uu000e15otrkd91287?fresh=true"
}


struct MyMapView: UIViewRepresentable {
    
    @EnvironmentObject var mapData: MyMapViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = mapData.mapView
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        return MyMapView.Coordinator()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    class Coordinator: NSObject {
        
    }
}
