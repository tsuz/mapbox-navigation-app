//
//  ContentView.swift
//  Shared
//
//  Created by Taku Suzuki on 2022/03/22.
//

import SwiftUI
import MapboxDirections

struct ContentView: View {
    @StateObject var originData = SearchViewModel()
    @StateObject var destData = SearchViewModel()
    @StateObject var mapData = MyMapViewModel()
    @State var showNavigation = false
    @FocusState private var focusedField: SearchType?
    @State private var selectedRouteIdx: Int? = 0
    @State private var offset: CGFloat = 0.0
    @State private var showRouteDetail: Bool = false
    
    var routeCount: Int {
        mapData.searchedRoute?.routes?.count ?? 0
    }
    
    var body: some View {
        
        GeometryReader { geom in
            ZStack {
                MyMapView()
                    .environmentObject(mapData)
                    .ignoresSafeArea(.all, edges: .all)
                
                if showNavigation {
                    NavigationView(showLoading: $showNavigation,
                                   origin: $mapData.origin,
                                   destination: $mapData.destination)
                }
                
                VStack {
                    HStack(alignment: .top) {
                        Image(systemName: "play")
                            .foregroundColor(.gray)
                        TextField("出発地", text: $originData.searchText)
                            .focused($focusedField, equals: SearchType.origin)
                            .colorScheme(.light)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.white)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "flag")
                            .foregroundColor(.gray)
                        TextField("目的地", text: $destData.searchText)
                            .focused($focusedField, equals: SearchType.destination)
                            .colorScheme(.light)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.white)
                    
                    if focusedField == .origin && !originData.places.isEmpty && originData.searchText != "" {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(originData.places) { place in
                                    Text(place.place.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture {
                                            guard let coord = place.place.location?.coordinate else {
                                                return
                                            }
                                            mapData.origin = Waypoint(coordinate: coord, name: place.place.name)
                                            mapData.searchRoute()
                                            if let name = place.place.name {
                                                originData.searchText = name
                                            }
                                            
                                            self.focusedField = nil
                                        }
                                    Divider()
                                }
                                .padding(.top, 10)
                            }
                        }
                        .background(.white)
                    }
                    
                    if focusedField == .destination && !destData.places.isEmpty && destData.searchText != "" {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(destData.places) { place in
                                    Text(place.place.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture {
                                            // was checked earlier
                                            let coord = place.place.location!.coordinate
                                            mapData.destination = Waypoint(coordinate: coord, name: place.place.name)
                                            mapData.searchRoute()
                                            if let name = place.place.name {
                                                destData.searchText = name
                                            }
                                            focusedField = nil
                                        }
                                    Divider()
                                }
                                .padding(.top, 10)
                            }
                        }
                        .background(.white)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                
                Spacer()
                
                if routeCount > 0 {
                    Group{
                        SwipeableRoutesView(
                            routeResponse: $mapData.searchedRoute, selectedRouteIdx: $selectedRouteIdx
                        )
                            .modifier(AnimatableViewModifier(
                                height: routeCount > 0 ?
                                (showRouteDetail ? geom.size.height : SwipeableRoutesView.height): 0))
                            .offset(y: offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        print("Value start Y", value.startLocation.y, value.translation.height)
                                        offset = value.translation.height
                                    }
                                    .onEnded { _ in
                                        print("Offset", offset, geom.size.height)
                                        if offset < -50 {
                                            // not sure where 200 came from
                                            offset = -1 * (geom.size.height - SwipeableRoutesView.height - SwipeableRoutesView.height)
                                            showRouteDetail = true
                                        } else {
                                            offset = 0
                                            showRouteDetail = false
                                        }
                                    }
                            )
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()
                }
            }
        }
        .onChange(of: originData.searchText, perform: { newValue in
            if focusedField != .origin {
                focusedField = .origin
            }
            self.originData.searchQuery()
        })
        .onChange(of: destData.searchText, perform: { newValue in
            if focusedField != .destination {
                focusedField = .destination
            }
            self.destData.searchQuery()
        })
        .onChange(of: selectedRouteIdx, perform: { newValue in
            print("$selectedRouteIdx", newValue)
            print("routeResponse", mapData.searchedRoute)
            guard let idx = newValue else {
                return
            }
            mapData.selectRoute(index: idx)
        })
    }
    
}

