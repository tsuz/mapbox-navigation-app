//
//  SwipeableRoutesView.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/29.
//

import SwiftUI
import MapboxDirections
import MapKit

let today = Date()
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!

struct SwipeableRoutesView: View {
    
    static var height: CGFloat = 300
    
    @Binding var routeResponse: RouteResponse?
    
    @Binding var selectedRouteIdx: Int?
    
    @State var showingSubview = false
    
    @State private var offset: CGFloat = 0.0
    
    
    var selectedRoute: Route? {
        guard let idx = selectedRouteIdx else {
            return nil
        }
        guard let routes = self.routeResponse?.routes else {
            return nil
        }
        return routes[idx]
    }
    
    var routeCount: Int {
        routeResponse?.routes?.count ?? 0
    }
    
    var routes: [Route] {
        routeResponse?.routes ?? []
    }
    
    var distanceFormatter: MKDistanceFormatter {
        let df = MKDistanceFormatter()
        df.unitStyle = .abbreviated
        return df
    }
    
    var distance: Int {
        Int(selectedRoute?.distance ?? 0)
    }
    
    var distanceString: String {
        guard let str = distanceFormatter.string(for: distance) else {
            return ""
        }
        return String(describing: str)
    }

    var longTimeFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }
    
    var timeOnlyFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }
    
    var departureTime: String {
        longTimeFormatter.string(from: Date())
    }
    
    var arrivalTime: String {
        timeOnlyFormatter.string(from:
                                    Date().adding(seconds: Int(selectedRoute?.expectedTravelTime ?? 0))
        )
    }
    
    var body: some View {
        GeometryReader { geom in
            VStack {
                Spacer()
                HStack {
                    // Title
                    Spacer()
                    
                    ForEach(Array(routes.enumerated()), id: \.offset) { idx, element in
                        Text("Route \(idx+1)")
                            .tint(.blue)
                            .foregroundColor(selectedRouteIdx == idx ? .blue : .gray)
                            .onTapGesture {
                                print("onTapGesture")
                                selectedRouteIdx = idx
                            }
                        Spacer()
                    }
                }.padding(16)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text("\(distanceString)")
                            Text("渋滞")
                        }
                        
                        Spacer()
                        
                        HStack {
                            if selectedRoute?.expectedTravelTime != nil {
                                Text("\(departureTime)")
                                Text("-")
                                Text("\(arrivalTime)")
                            }
                        }
                        Spacer()
                        
                        HStack {
                            Text("所要時間グラフ 開く")
                        }
                        Spacer()
                    }
                    Spacer()
                    
                    Button {
                        
                    } label:{
                        Text("かいし")
                    }
                }.padding(16)
                
                Divider()
                
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("ルート詳細")
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("日時変更")
                    }
                    Spacer()
                }
                .padding(16)
                .padding(.bottom, 32)
                

                VStack(alignment: .leading) {
                    if let route = selectedRoute {
                        TimelineList(route)
                    }
                }
                .frame(width: geom.size.width,
                       height: geom.size.height)
                
            }
            .frame(width: geom.size.width, height: SwipeableRoutesView.height, alignment: .bottom)
        }
        .background(.white)
        .cornerRadius(16)
        .foregroundColor(.black)
    }
}

extension Date {
    func adding(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

struct SwipeableRoutesView_Previews: PreviewProvider {
    
    @State static var routeResponse: RouteResponse?
    
    @State static var selectedRouteIdx: Int?
    
    static var previews: some View {
        SwipeableRoutesView(routeResponse: $routeResponse, selectedRouteIdx: $selectedRouteIdx)
    }
}
