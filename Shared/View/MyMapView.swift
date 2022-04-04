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


//
//class MyMapView: MapView {
//
//    internal let defaultCameraOptions = CameraOptions(
//        center: CLLocationCoordinate2D(
//            latitude: 35.6398303,
//            longitude: 139.7488775
//        ),
//        zoom: 18.56,
//        pitch: 62
//    )
//
//    init(frame: CGRect,
//         onMapLoad: (() -> Void)? = nil) {
//        let mapInitOpts = MapInitOptions(
//         cameraOptions: defaultCameraOptions,
//         styleURI: StyleURI(rawValue: MapStyle.threeDimensionBuildings.rawValue))
//        super.init(frame: frame, mapInitOptions: mapInitOpts)
//        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        self.mapboxMap.onNext(.mapLoaded) { [self] _ in
//            self.initializeMap()
//            onMapLoad?()
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func initializeMap() {
//        self.setLang()
//    }
//
//    private func setLang() {
//        var locale = "en"
//        if let deviceLocale = NSLocale.current.languageCode {
//            locale = deviceLocale
//        }
//        try? self.mapboxMap.style.localizeLabels(
//         into: Locale(identifier: locale))
//    }
//
//    private func addWidgets() {
//
//    }
//}
//
