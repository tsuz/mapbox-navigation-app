//
//  AnimatableViewModifier.swift
//  mapbox-navigation-jp
//
//  Created by Taku Suzuki on 2022/03/29.
//

import SwiftUI

struct AnimatableViewModifier: AnimatableModifier {
    var height: CGFloat = 0

    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
