//
//  NavigationView.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/24.
//

import SwiftUI
import UIKit
import MapboxMaps
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

struct NavigationView : UIViewControllerRepresentable {
    
    @Binding var showLoading: Bool
    
    @Binding var origin: Waypoint?
    
    @Binding var destination: Waypoint?
    
    func makeUIViewController(context: Context) -> MyNavigationViewController {
        let vc = MyNavigationViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MyNavigationViewController, context: Context) {
        if showLoading == true {
            guard let origin = origin,
                  let destination = destination else {
                      return
                  }
            uiViewController.startNavigation(
                origin: origin,
                destination: destination)
        } else {
            uiViewController.stopNavigation()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(showLoading: $showLoading)
    }
    
    // Coordinator receives delegate and handles showLoading state
    class Coordinator: NavigationViewControllerDelegate {
        
        @Binding var showLoading: Bool
        
        init(showLoading: Binding<Bool>) {
            _showLoading = showLoading
        }

        func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
            navigationViewController.dismiss(animated: true, completion: nil)
            showLoading = false
        }
    }
}

class MyNavigationViewController: UIViewController {
    
    var delegate: NavigationViewControllerDelegate?
    
    public func startNavigation(origin: Waypoint,
                                destination: Waypoint) {
        
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
                // Pass the generated route response to the the NavigationViewController
                let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions)
                guard let navigationMapView = viewController.navigationMapView else {
                    return
                }
                viewController.modalPresentationStyle = .fullScreen
                navigationMapView.mapView.mapboxMap.style.uri = StyleURI(rawValue: MapStyle.threeDimensionBuildings.rawValue)
                
                // Modify default `NavigationViewportDataSource` and `NavigationCameraStateTransition` to change
                // `NavigationCamera` behavior during free drive and when locations are provided by Maps SDK directly.
                navigationMapView.navigationCamera.viewportDataSource = MyViewportDataSource(navigationMapView.mapView)
                //                navigationMapView.navigationCamera.cameraStateTransition = MyCustomTransition(navigationMapView.mapView)
                viewController.delegate = self?.delegate
                strongSelf.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    public func stopNavigation() {
        dismiss(animated: true, completion: nil)
    }
}
