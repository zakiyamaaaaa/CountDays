//
//  BounceButtonStyle.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import Foundation
import SwiftUI

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
