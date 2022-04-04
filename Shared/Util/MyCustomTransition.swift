//
//  MyCustomTransition.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/22.
//

import MapboxMaps
import MapboxNavigation

/**
 Custom implementation of Navigation Camera transitions, which conforms to `CameraStateTransition`
 protocol.
 
 To be able to use custom camera transitions user has to create instance of `CustomCameraStateTransition`
 and then override with it default implementation, by modifying
 `NavigationMapView.NavigationCamera.CameraStateTransition` or
 `NavigationViewController.NavigationMapView.NavigationCamera.CameraStateTransition` properties.
 
 By default Navigation SDK for iOS provides default implementation of `CameraStateTransition`
 in `NavigationCameraStateTransition`.
 */
class MyCustomTransition: CameraStateTransition {
    
    internal let duration = 0.2

    func update(to cameraOptions: CameraOptions, state: NavigationCameraState) {
        mapView?.camera.ease(to: cameraOptions, duration: duration, curve: .linear, completion: nil)
    }
    
    weak var mapView: MapView?
    
    required init(_ mapView: MapView) {
        self.mapView = mapView
    }
    
    func transitionToFollowing(_ cameraOptions: CameraOptions, completion: @escaping (() -> Void)) {
        mapView?.camera.ease(to: cameraOptions, duration: duration, curve: .linear, completion: { _ in
            completion()
        })
    }
    
    func transitionToOverview(_ cameraOptions: CameraOptions, completion: @escaping (() -> Void)) {
        mapView?.camera.ease(to: cameraOptions, duration: duration, curve: .linear, completion: { _ in
            completion()
        })
    }
    
    func updateForFollowing(_ cameraOptions: CameraOptions) {
        mapView?.camera.ease(to: cameraOptions, duration: duration, curve: .linear, completion: nil)
    }
    
    func updateForOverview(_ cameraOptions: CameraOptions) {
        mapView?.camera.ease(to: cameraOptions, duration: duration, curve: .linear, completion: nil)
    }
    
    func cancelPendingTransition() {
        mapView?.camera.cancelAnimations()
    }
}
