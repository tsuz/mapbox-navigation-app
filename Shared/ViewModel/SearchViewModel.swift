//
//  ContentViewModel.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/24.
//

import SwiftUI
import MapKit

enum SearchType {
    case origin
    case destination
}

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var places: [Place] = []
    
    func searchQuery() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        MKLocalSearch(request: request).start { (response, err) in
            guard let result = response else { return }
            self.places = result.mapItems.compactMap({ (item) -> Place? in
                return item.placemark.location?.coordinate == nil
                ? nil
                : Place(place: item.placemark)
            })
        }
    }
}
