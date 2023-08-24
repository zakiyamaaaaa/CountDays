//
//  ViewExtension.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/23.
//

import Foundation
import SwiftUI

struct IsHidden: ViewModifier {
    var hidden = false
    var remove = false
    func body(content: Content) -> some View {
        if hidden && !remove {
            content.hidden()
        } else {
            content
        }
    }
}

extension View {
    func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
        modifier(
            IsHidden(hidden: hidden, remove: remove)
        )
    }
}
