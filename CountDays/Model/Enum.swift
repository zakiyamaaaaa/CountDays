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
    case calendar = 2
}

enum DisplayLang: Int, PersistableEnum {
    case jp = 0
    case en = 1
    
    var dateText: (day:String, hour: String, minute:String, second: String) {
        switch self {
        case .jp:
            return ("日","時間","分","秒")
        case .en:
            return ("Day","Hour","Min","Second")
        }
    }
    
    /// カレンダーの表記用
    var identifier: String {
        switch self {
        case .jp:
            return "ja_JP"
        case .en:
            return "en_US"
        }
    }
    
    var finishText: String {
        switch self {
        case .jp:
            return "終了"
        case .en:
            return "Finish"
        }
    }
}

enum EventType: String, CaseIterable, Identifiable, PersistableEnum {
    case countdown = "カウントダウン"
    case countup = "カウントアップ"
    var id: String { rawValue }
}

enum FrequentType: String, CaseIterable, Identifiable, PersistableEnum {
    case never = "繰り返さない"
    case annual = "毎年繰り返す"
    case monthly = "毎月繰り返す"
    case weekly = "毎週繰り返す"
//    case daily = "毎日繰り返す"
    
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
        }
    }
}

enum DayOfWeek: Int, CaseIterable, PersistableEnum {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    var stringValue: String {
        switch self {
        case .sunday:
            return "日曜日"
        case .monday:
            return "月曜日"
        case .tuesday:
            return "火曜日"
        case .wednesday:
            return "水曜日"
        case .thursday:
            return "木曜日"
        case .friday:
            return "金曜日"
        case .saturday:
            return "土曜日"
        }
    }
}
