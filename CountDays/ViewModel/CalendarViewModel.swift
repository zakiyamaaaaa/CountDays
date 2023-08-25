//
//  CalendarViewModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/06/03.
//

import Foundation

class CalendarViewModel: ObservableObject {
    
    static var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }()
    
    static func getDay(to: Date, frequentType: FrequentType, dayAtMonthly: Int = 1) -> Int? {
        
        switch frequentType {
        case .annual: /// 毎年カウント
            return ((calendar.dateComponents([.day], from: to, to: Date()).day ?? 1) % 365)
        case .monthly: /// 毎月カウント
            let day = (calendar.dateComponents([.month, .day], from: to, to: Date()).day ?? 0) - dayAtMonthly + 1
            return day
        case .weekly: /// 毎週カウント
            let today = calendar.component(.weekday, from: Date())
            let target = calendar.component(.weekday, from: to)
            let day = (today - target) < 0 ? today - target + 7 : today - target
            
            return day
        case .never:
            return calendar.dateComponents([.day], from: to, to: Date()).day
        }
    }
    
    static func getMonth(to: Date) -> Int? {
        return calendar.dateComponents([.day], from: to, to: Date()).month
    }
    
    static func getHour(to: Date) -> Int? {
        return (calendar.dateComponents([.hour], from: to, to: Date()).hour ?? 1)%24
    }
    
    static func getMinute(to: Date) -> Int? {
        return (calendar.dateComponents([.minute], from: to, to: Date()).minute ?? 1)%60
    }
    
    static func getSecond(to: Date) -> Int? {
        return (calendar.dateComponents([.second], from: to, to: Date()).second ?? 1)%60
    }
}
