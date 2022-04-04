//
//  TimelineListView.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/04/02.
//

import SwiftUI
import MapboxDirections
import MapboxCoreNavigation


struct Appointment {
    let date: Date
    let message: String
}


struct TimelineList: View {
    // change these to visually style the timeline
    private static let lineWidth: CGFloat = 4
    private static let dotDiameter: CGFloat = 8
    
//    let items: [Appointment]
    let route: Route
    
    private let dateFormatter: DateFormatter
    
    init(_ route: Route) {
        self.route = route
        dateFormatter = DateFormatter()
        // the format of the dates on the timeline
        dateFormatter.dateFormat = "EEE\ndd"
    }

    private func distanceString(for distance: Double) -> String {
        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.unitStyle = .medium
        let measurement = Measurement(distance: distance)
        return distanceFormatter.string(from: measurement)
    }
    
//    init(_ items: [Appointment]) {
//        self.items = items
//        dateFormatter = DateFormatter()
//        // the format of the dates on the timeline
//        dateFormatter.dateFormat = "EEE\ndd"
//    }
//
    
    var body: some View {
        List(Array(route.legs.enumerated()), id: \.offset) { index, item in
            routeLeg(index, item: item)
            // removes spacing between the rows
                .listRowInsets(EdgeInsets())
            // hides separators on SwiftUI 3, for other versions
            // check out https://swiftuirecipes.com/blog/remove-list-separator-in-swiftui
                .listRowSeparator(.hidden)
        }
    }
    
//    var body: some View {
//        List(Array(items.enumerated()), id: \.offset) { index, item in
//            rowAt(index, item: item)
//            // removes spacing between the rows
//                .listRowInsets(EdgeInsets())
//            // hides separators on SwiftUI 3, for other versions
//            // check out https://swiftuirecipes.com/blog/remove-list-separator-in-swiftui
//                .listRowSeparator(.hidden)
//        }
//    }
    
    @ViewBuilder private func routeLeg(_ index: Int, item: RouteLeg) -> some View {
        ForEach(0..<item.steps.count) { i in
            routeStep(i, item: item.steps[i], hasNext: i + 1 < item.steps.count)
        }
    }
    
    @ViewBuilder private func routeStep(_ index: Int, item: RouteStep, hasNext: Bool) -> some View {
        let calendar = Calendar.current
        let hasPrevious = index > 0
//        let hasNext = index < items.count - 1
//        let isPreviousSameDate = hasPrevious && calendar.isDate(date, inSameDayAs: items[index - 1].date)
        let isPreviousSameDate = false
        
        HStack {
            ZStack {
                Color.clear // effectively centers the text
                if !isPreviousSameDate {
                    VStack {
                        Text("09:37")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    
                        Spacer()
                        
                        Text(distanceString(for: item.distance))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                }
            }
            .frame(width: 50)

            GeometryReader { geo in
                ZStack {
                    Color.clear
                    line(height: geo.size.height,
                         hasPrevious: hasPrevious,
                         hasNext: hasNext,
                         isPreviousSameDate: isPreviousSameDate)
                }
            }
            .frame(width: 10)

            VStack(alignment: .leading) {
                Text(item.maneuverType.rawValue)
                
                if let names = item.names {
                    ForEach(0..<names.count) { i in
                        Text(names[i])
                    }
                }
            }
        }
        Spacer()
    }
    
    
    
//    @ViewBuilder private func rowAt(_ index: Int, item: Appointment) -> some View {
//        let calendar = Calendar.current
//        let date = item.date
//        let hasPrevious = index > 0
//        let hasNext = index < items.count - 1
//        let isPreviousSameDate = hasPrevious
//        && calendar.isDate(date, inSameDayAs: items[index - 1].date)
//
//        HStack {
//            ZStack {
//                Color.clear // effectively centers the text
//                if !isPreviousSameDate {
//                    Text("09:37")
//                        .font(.system(size: 14))
//                        .multilineTextAlignment(.center)
//                }
//            }
//            .frame(width: 50)
//
//            GeometryReader { geo in
//                ZStack {
//                    Color.clear
//                    line(height: geo.size.height,
//                         hasPrevious: hasPrevious,
//                         hasNext: hasNext,
//                         isPreviousSameDate: isPreviousSameDate)
//                }
//            }
//            .frame(width: 10)
//
//            Text(item.message + " (300m)")
//        }
//    }
    
    // this methods implements the rules for showing dots in the
    // timeline, which might differ based on requirements
    @ViewBuilder private func line(height: CGFloat,
                                   hasPrevious: Bool,
                                   hasNext: Bool,
                                   isPreviousSameDate: Bool) -> some View {
        let lineView = Rectangle()
            .foregroundColor(
                Color.init(red: 211/255.0, green: 211/255.0, blue: 211/255.0)
            )
            .frame(width: TimelineList.lineWidth)
        
        let dot = Circle()
            .fill(Color.gray)
            .frame(width: TimelineList.dotDiameter,
                   height: TimelineList.dotDiameter)
        
        let halfHeight = height / 2
        let quarterHeight = halfHeight / 2
        if isPreviousSameDate && hasNext {
            lineView
        } else if hasPrevious && hasNext {
            lineView
            dot
        } else if hasNext {
            lineView
                .frame(height: halfHeight)
                .offset(y: quarterHeight)
            dot
        } else if hasPrevious {
            lineView
                .frame(height: halfHeight)
                .offset(y: -quarterHeight)
            dot
        } else {
            dot
        }
    }
}

