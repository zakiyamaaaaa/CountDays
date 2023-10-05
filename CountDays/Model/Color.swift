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
    case white
    case yellow
    case blue
    case red
    case mint
    case indigo
    case pink
    case teal
    case none
    
    var color: Color? {
        switch self {
        case .primary:
            return .primary
        case .white:
            return .white
        case .mint:
            return .mint
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
        case .none:
            return nil
        }
    }
    
    var gradient: LinearGradient? {
        switch self {
        case .primary:
            return LinearGradient(colors: [ColorUtility.primary, ColorUtility.secondary], startPoint: UnitPoint(x: 0.5, y: 1), endPoint: UnitPoint(x: 0.5, y: 0))
        case .white:
            return LinearGradient(colors: [.white, .white], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .mint:
            return LinearGradient(colors: [Color(red: 0.0, green: 0.78, blue: 0.75), Color(red: 0.35, green: 0.9, blue: 0.89)], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .blue:
            return LinearGradient(colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.4, green: 0.52, blue: 1.0)], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .pink:
            return LinearGradient(colors: [.pink, .pink.dark()], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .red:
            return LinearGradient(colors: [.red, .red.dark()], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        
        case .indigo:
            return LinearGradient(colors: [.indigo, .indigo.dark()], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .yellow:
            return LinearGradient(colors: [.yellow, .yellow.dark()], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .teal:
            return LinearGradient(colors: [Color(red: 0.19, green: 0.69, blue: 0.78), Color(red: 0.25, green: 0.78, blue: 0.88, opacity: 1.0)], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1))
        case .none:
            return nil
        }
    }
}

extension Color {
    
    func dark(brightnessRatio: CGFloat = 1.6) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        let color = UIColor(self)
    
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return Color(hue: hue, saturation: saturation*brightnessRatio, brightness: brightness, opacity: alpha)
        }
        return self
    }
}
