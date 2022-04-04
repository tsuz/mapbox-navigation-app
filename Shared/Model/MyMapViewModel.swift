//
//  MyMapViewModel.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/24.
//

import SwiftUI
import MapboxMaps
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class MyMapViewModel: ObservableObject {
    
    @Published var mapView = MapView(
        frame: .zero,
        mapInitOptions: MapInitOptions(
            cameraOptions: CameraOptions(
                center: CLLocationCoordinate2D(
                    latitude: 35.6398303,
                    longitude: 139.7488775
                ),
                zoom: 18.56,
                pitch: 62
            ),
            styleURI: StyleURI(rawValue: MapStyle.threeDimensionBuildings.rawValue)))
    
    @Published var origin: Waypoint?
    
    @Published var destination: Waypoint?
    
    @Published var loaded = false
    
    @Published var searchedRoute: RouteResponse?
    
    internal var shownRoutes: [String] = []
    internal var unselectedColor: Value<StyleColor> = .constant(StyleColor(.gray))
    internal var selectedColor: Value<StyleColor> = .constant(StyleColor(.blue))
    
    var routeLayerIds: [String] = []
    
    init() {
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.loaded = true
            self.setLang()
        }
    }
    
    private func setLang() {
        var locale = "en"
        if let deviceLocale = NSLocale.current.languageCode {
            locale = deviceLocale
        }
        try? mapView.mapboxMap.style.localizeLabels(
            into: Locale(identifier: locale))
    }
    
    func updateLocation(_ coords: CLLocationCoordinate2D) {
        let camera = self.mapView.cameraState
        let option = CameraOptions(center: coords,
                                   padding: camera.padding,
                                   anchor: nil,
                                   zoom: 18,
                                   bearing: 0,
                                   pitch: 0)
        self.mapView.camera.fly(to: option,
                                duration: 1,
                                completion: nil)
    }
    
    func searchRoute() {
        guard let origin = origin,
              let destination = destination else {
                  
                  return
              }
        searchedRoute = nil
        
        removePreviousRoutes()
        
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination])
        
        // Request a route using MapboxDirections
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                guard let routes = response.routes else {
                    return
                }
                
                strongSelf.searchedRoute = response
                
                var idx = 0
                var allCoords: [CLLocationCoordinate2D] = []
                for route in routes {
                    let key = strongSelf.generateKey(idx)
                    var source = GeoJSONSource()
                    source.data = .feature(Feature(geometry: route.shape?.geometry))
                    try! strongSelf.mapView.mapboxMap.style.addSource(source, id: key)
                    
                    var lineLayer = LineLayer(id: key)
                    lineLayer.source = key
                    lineLayer.lineColor = strongSelf.unselectedColor
                    lineLayer.lineWidth = .constant(4.0)
                    try! strongSelf.mapView.mapboxMap.style.addLayer(lineLayer)
                    
                    idx = idx + 1
                    strongSelf.shownRoutes.append(key)
                    
                    if let coordinates = route.shape?.coordinates {
                        allCoords.append(contentsOf: coordinates)
                    }
                }
                guard routes.count > 0 else {
                    return
                }
                strongSelf.selectRoute(index: 0)
                let newCameraOpts = strongSelf.mapView.mapboxMap.camera(
                    for: allCoords,
                       padding: .init(top: 20.0, left: 15.0, bottom: 105.0, right: 15.0),
                       bearing: 0,
                       pitch: 0)
                strongSelf.mapView.camera.fly(to: newCameraOpts,
                                              duration: 0.5,
                                              completion: nil)
            }
        }
    }
    
    func selectRoute(index: Int) {
        let style = self.mapView.mapboxMap.style
        let selectedLayerId = generateKey(index)
        guard var routeLayer = try? style.layer(withId: selectedLayerId) as? LineLayer else {
            return
        }
        
        // remove the selected one and insert above
        try? style.removeLayer(withId: selectedLayerId)
        
        guard let firstLayer = style.allLayerIdentifiers.last else {
            return
        }
        
        // make non-selected routes gray
        for (idx, layerId) in shownRoutes.enumerated() {
            if let layer = try? style.layer(withId: layerId) as? LineLayer {
                if idx != index
                    && layer.lineColor != unselectedColor {
                    // selectedColor doesn't seem to work
                    try? style.setLayerProperty(for: layerId, property: "line-color", value: "gray")
                }
            }
        }
        
        // add selected route
        routeLayer.lineColor = selectedColor
        try? style.addLayer(routeLayer, layerPosition: .above(firstLayer.id))
    }
    
    private func removePreviousRoutes() {
        for layerId in shownRoutes {
            let style = self.mapView.mapboxMap.style
            if let layer = try? style.layer(withId: layerId) {
                try! style.removeLayer(withId: layer.id)
            }
            if style.sourceExists(withId: layerId) {
                try! style.removeSource(withId: layerId)
            }
        }
    }
    
    private func removePreviousRouteLayer() {
        for layerId in shownRoutes {
            let style = self.mapView.mapboxMap.style
            if let layer = try? style.layer(withId: layerId) {
                try! style.removeLayer(withId: layer.id)
            }
        }
    }
    
    private func generateKey(_ idx: Int) -> String {
        return "route-\(idx)"
    }
}
