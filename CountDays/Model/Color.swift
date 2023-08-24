//
//  ColorList.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/06/03.
//

import SwiftUI
import RealmSwift

enum TextColor: String, RawRepresentable, PersistableEnum {
    case black
    case white
    case blue
    case red
    case yellow
    case pink
    case purple
    case mint
    case green
    
    var color: Color {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .red:
            return .red
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .mint:
            return .mint
        case .green:
            return .green
        }
    }
}

enum BackgroundColor: String, RawRepresentable, CaseIterable, PersistableEnum {
    case primary
    case mint
    case white
    case blue
    case red
    case yellow
    case pink
    case indigo
    case teal
    
    var color: Color {
        switch self {
        case .primary:
            return .primary
        case .mint:
            return .mint
        case .white:
            return .white
        case .pink:
            return .pink
        case .red:
            return .red
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .teal:
            return .teal
        case .yellow:
            return .yellow
        }
    }
}
