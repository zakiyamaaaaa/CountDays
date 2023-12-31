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
        cal.locale = Locale.current
        return cal
    }()
    
    
    static func getDates(target: Date, eventType: EventType, frequentType: FrequentType, dayOfWeek: DayOfWeek = .sunday, current: Date = Date()) -> (fixedDate: Date, days: Int, hours: Int, minutes: Int, seconds: Int) {
        
        switch eventType {
        case .countup:
            let component = calendar.dateComponents([.day, .hour, .minute, .second], from: target, to: current)
            return (target, component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
        case .countdown:
            
            switch frequentType {
            case .never:
                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: current, to: target)
                return (target, component.day ?? 1, component.hour  ?? 0, component.minute ?? 0, component.second ?? 0)
            case .annual:
                return getAnnualDate(target: target)
            case .monthly:
                /// 日にち、時間、分をDate()にセット
                /// セットした日付が過去なら月に+1
                let day = calendar.dateComponents([.day, .hour, .minute, .second], from: target).day!
                let hour = calendar.dateComponents([.day, .hour, .minute, .second], from: target).hour!
                let minute = calendar.dateComponents([.day, .hour, .minute, .second], from: target).minute!
                let second = calendar.dateComponents([.day, .hour, .minute, .second], from: target).second!

                var date = calendar.date(bySetting: .day, value: day, of: current)!
                date = calendar.date(bySettingHour: hour, minute: minute, second: second, of: date)!
                
                if isPastDate(date) {
                    date = calendar.date(byAdding: .month, value: 1, to: date)!
                }
                
                let component = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: current, to: date)
//                if isPastDate(date) {
//                    component.month! += 1
//                }
                
                return (date, component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
            case .weekly:
//                print("target")
//                print(target)
//                let weekday = DayOfWeek(rawValue: dayOfWeek.rawValue)?.rawValue ?? 0
//                let today = calendar.component(.weekday, from: Date())
                let hour = calendar.dateComponents([.day, .hour, .minute, .second], from: target).hour!
                let minute = calendar.dateComponents([.day, .hour, .minute, .second], from: target).minute!
                let second = calendar.dateComponents([.day, .hour, .minute, .second], from: target).second!
                let weekday = dayOfWeek.rawValue
                let today = calendar.component(.weekday, from: current) - 1
                let diff = abs(weekday - today)
                
                var updateDate = calendar.date(bySettingHour: hour, minute: minute, second: second, of: current)!
                updateDate = calendar.date(byAdding: .day, value: diff, to: updateDate)!
                
                if isPastDate(updateDate) {
                    updateDate = calendar.date(byAdding: .day, value: 7, to: updateDate)!
                }
                
//                return updateDate
//                let diff = weekday - today < 0 ? weekday - today + 7 : weekday - today
//                var a = calendar.date(bySettingHour: hour, minute: minute, second: second, of: Date())!
//                a = calendar.date(byAdding: .day, value: -diff, to: a)!
                /// もし入力値がマイナスなら、1週間後にする
//                if a.timeIntervalSince(Date()) < 0 {
//                    a.addTimeInterval(60*60*24*7)
//                }
                
                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: current, to: updateDate)
                
//                let today = calendar.component(.weekday, from: Date())
//                let target = calendar.component(.weekday, from: target)
                /// ここで処理するのがいいか
                /// それとも日付選択画面のところで、先に処理したほうがいいか
                /// 先に処理した場合、dayOfWeekを持たなくてもよくなるけど、日付選択画面での処理が増える
//                let day = (target - today) < 0 ? target - today + 7 : target - today
//                let date = calendar.date(bySetting: .day, value: day, of: Date())
//                let component = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date!)
                return (updateDate, component.day ?? 1, component.hour ?? 0, component.minute ?? 0, component.second ?? 0)
            }
        }
    }
    
    /// フォーマットされた日付に変換
    static func getFormattedDate(_ eventVM: EventCardViewModel2, locale: Locale) -> String {
        let format = DateFormatter()
        format.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM\nHH:mm", options: 0, locale: Locale(identifier: locale.identifier))
        return format.string(from: eventVM.selectedDate)
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
    
    static func getRemainSecond(target: Date, updatedDate: Date? = nil, eventType: EventType, frequentType: FrequentType, dayOfweek: DayOfWeek = .sunday) -> Int? {
        switch eventType {
        case .countup:
            return calendar.dateComponents([.second], from: target, to: Date()).second
        case .countdown:
            
            switch frequentType {
            case .never:
                let date = updatedDate ?? Date()
                return calendar.dateComponents([.second], from: date, to: target).second
            case .annual:
                let thisYear = calendar.dateComponents([.year], from: Date()).year
                var component = calendar.dateComponents([.second], from: target)
                
                /// 日付が過去の場合
                if isPastDate(target) {
                    component.year = thisYear! + 1
                }
                let targetDate = DateComponents(calendar: calendar, year: component.year, month: component.month, day: component.day, hour: component.hour, minute: component.minute, second: component.second).date
                return calendar.dateComponents([.second], from: Date(), to: targetDate!).second
            case .monthly:
                let day = calendar.dateComponents([.day], from: target).day!
                let date = calendar.date(bySetting: .day, value: day, of: Date())
                
                return calendar.dateComponents([.second], from: Date(), to: date!).second
            case .weekly:
                var a = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: target)!
                /// もし入力値がマイナスなら、1週間後にする
                if a.timeIntervalSince(Date()) < 0 {
                    a.addTimeInterval(60*60*24*7)
                }
                
                return calendar.dateComponents([.second], from: Date(), to: a).second
            }
        }
    }
    
    /// 毎年観測する場合の日付データ
    static func getAnnualDate(target: Date) -> (fixedDate: Date, days: Int, hours: Int, minutes: Int, seconds: Int) {
//        var targetDate = target
        let thisYear = calendar.dateComponents([.year], from: Date()).year
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: target)
        component.year = thisYear
        
        /// 年を今年にしたものを過去のものかどうか
        /// 過去のものであれば、年を+1する
        let date = calendar.date(from: component)!
        if isPastDate(date) {
            component.year! += 1
        }
//        /// 日付が過去の場合
//        if isPastDate(target) {
//            component.year = thisYear! + 1
//        } else {
//            component.year = thisYear!
//        }
        let targetDate = DateComponents(calendar: calendar, year: component.year, month: component.month, day: component.day, hour: component.hour, minute: component.minute, second: component.second).date
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: targetDate!)
        
        return (target, components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
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
    
    /// 当月の月末の日付を取得する
    static func getLastDayOfMonth() -> Int {
        let comps = calendar.dateComponents([.year, .month], from: Date())
        let firstDay = calendar.date(from: comps)!

        let add = DateComponents(month: 1, day: -1)
//        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        let range = calendar.range(of: .day, in: .month, for: Date())
        let lastDay = range?.last ?? 1
        print("今月の日数は\(lastDay)")
        return lastDay
    }
}
