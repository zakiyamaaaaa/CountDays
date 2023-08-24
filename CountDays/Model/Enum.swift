//
//  EventDisplayStyle.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/06/03.
//

import Foundation
import RealmSwift
import SwiftUI

enum EventDisplayStyle: Int, CaseIterable, PersistableEnum {
    case standard = 0
    case circle = 1
}

enum EventType: String, CaseIterable, Identifiable, PersistableEnum {
    case countdown = "カウントダウン"
    case countup = "カウントアップ"
    var id: String { rawValue }
}

enum FrequentType: String, CaseIterable, Identifiable, PersistableEnum {
    case never = "繰り返さない"
    case annual = "年に一度繰り返す"
    case monthly = "毎月繰り返す"
    case weekly = "週に一度繰り返す"
    case daily = "毎日繰り返す"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .never:
            return .blue
        case .annual:
            return .orange
        case .monthly:
            return .red
        case .weekly:
            return .mint
        case .daily:
            return .indigo
        }
    
    }
}
