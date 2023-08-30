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
        cal.locale = Locale(identifier: "ja_JP")
//        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }()
    
    static func getDates(target: Date, eventType: EventType, frequentType: FrequentType, dayOfWeek: DayOfWeek = .sunday) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        
        switch eventType {
        case .countup:
            let component = calendar.dateComponents([.day, .hour, .minute, .second], from: target, to: Date())
            return (component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
        case .countdown:
            
            switch frequentType {
            case .never:
                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: target)
                return (component.day ?? 1, component.hour  ?? 0, component.minute ?? 0, component.second ?? 0)
            case .annual:
                return getAnnualDate(target: target)
            case .monthly:
                let day = calendar.dateComponents([.day], from: target).day!
                let date = calendar.date(bySetting: .day, value: day, of: Date())
                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date!)
                
                return (component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
            case .weekly:
//                print("target")
//                print(target)
                var a = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: target)!
                /// もし入力値がマイナスなら、1週間後にする
                if a.timeIntervalSince(Date()) < 0 {
                    a.addTimeInterval(60*60*24*7)
                }
                
                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: a)
                
//                let today = calendar.component(.weekday, from: Date())
//                let target = calendar.component(.weekday, from: target)
                /// ここで処理するのがいいか
                /// それとも日付選択画面のところで、先に処理したほうがいいか
                /// 先に処理した場合、dayOfWeekを持たなくてもよくなるけど、日付選択画面での処理が増える
//                let day = (target - today) < 0 ? target - today + 7 : target - today
//                let date = calendar.date(bySetting: .day, value: day, of: Date())
//                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date!)
                return (component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
            }
        }
    }
    
    static func getDay(target: Date, eventType: EventType, frequentType: FrequentType) -> Int? {
        
        var fromDate = Date()
        var toDate = Date()

        switch eventType {
        case .countup:
            fromDate = target
        case .countdown:
            toDate = target
        }
        
        switch frequentType {
        case .annual: /// 毎年カウント
            
            return ((calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 1) % 365)
        case .monthly: /// 毎月カウント
            let day = (calendar.dateComponents([.month, .day], from: fromDate, to: toDate).day ?? 1)  + 1
            return day
        case .weekly: /// 毎週カウント
            let today = calendar.component(.weekday, from: Date())
            let target = calendar.component(.weekday, from: fromDate)
            let day = (today - target) < 0 ? today - target + 7 : today - target
            
            return day
        case .never:
            return calendar.dateComponents([.day], from: fromDate, to: Date()).day
        }
    }
    
    static func getMonth(target: Date, eventType: EventType) -> Int? {
        var fromDate = Date()
        var toDate = Date()
        
        switch eventType {
        case .countup:
            fromDate = target
        case .countdown:
            toDate = target
        }
        return calendar.dateComponents([.day], from: fromDate, to: toDate).month
    }
    
    static func getHour(target: Date, eventType: EventType) -> Int? {
        var fromDate = Date()
        var toDate = Date()
        
        switch eventType {
        case .countup:
            fromDate = target
        case .countdown:
            toDate = target
        }
        return (calendar.dateComponents([.hour], from: fromDate, to: toDate).hour ?? 0)%24
    }
    
    static func getMinute(target: Date, eventType: EventType) -> Int? {
        var fromDate = Date()
        var toDate = Date()
        
        switch eventType {
        case .countup:
            fromDate = target
        case .countdown:
            toDate = target
        }
        return (calendar.dateComponents([.minute], from: fromDate, to: toDate).minute ?? 0)%60
    }
    
    static func getSecond(target: Date, eventType: EventType) -> Int? {
        var fromDate = Date()
        var toDate = Date()
        
        switch eventType {
        case .countup:
            fromDate = target
        case .countdown:
            toDate = target
        }
        return (calendar.dateComponents([.second], from: fromDate, to: toDate).second ?? 0)%60
    }
    
    /// 毎年観測する場合の日付データ
    static func getAnnualDate(target: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
//        var targetDate = target
        let thisYear = calendar.dateComponents([.year], from: Date()).year
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: target)
        
        /// 日付が過去の場合
        if isPastDate(target) {
            component.year = thisYear! + 1
        }
        let targetDate = DateComponents(calendar: calendar, year: component.year, month: component.month, day: component.day, hour: component.hour, minute: component.minute, second: component.second).date
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate!)
        
        return (components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }
    
    /// 毎週観測する場合の日付データ
    /// 残りの日数を渡すことはできないので、ここでは指定された曜日の日付を返す
    static func getDateAtWeekly(dayAtWeek: DayOfWeek) -> Date {
        print("day at week")
        print(dayAtWeek)
        print(dayAtWeek.rawValue)
        
        
        var target = calendar.date(bySetting: .weekday, value: dayAtWeek.rawValue + 1, of: Date())!
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: target)!
//        target = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: target)!
//        let targetComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: target)
//        return DateComponents(calendar: calendar, day: targetComponent.day, hour: targetComponent.hour, minute: targetComponent.minute, second: targetComponent.second).date!
    }
    
    
    /// 日付が過去かどうかを判定する
    static func isPastDate(_ date: Date) -> Bool {
        let currentDate = Date()
        return date < currentDate
    }
}
