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
    
    static func getDay(to: Date) -> Int? {
        return calendar.dateComponents([.day], from: to, to: Date()).day
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
