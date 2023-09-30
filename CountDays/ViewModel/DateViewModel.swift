//
//  DateViewModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/28.
//

import Foundation

class DateViewModel: ObservableObject {
    @Published var selectedDate: Date = Date(timeIntervalSinceNow: -10000)
    
    static var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return formatter
    }()
    
    func dateText(date: Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja")
        dateFormatter.dateStyle = .medium
        let text = dateFormatter.string(from: date)
        return text
    }
    
    func dateText(component: DateComponents?) -> String {
        guard let component,
              let year = component.year?.description,
              let month = component.month?.description,
              let day = component.day?.description
        else {
            let date = Date()
            return dateText(date: date)
        }
        return "\(year)年\(month)月\(day)日"
    }
    
    func dateText(date: Date?) -> String {
        guard let date else {
            return "no data"
        }
        
        formatter.dateFormat = "yyyy'年'M'月'd'日"
//        guard let component,
//              let year = component.year?.description,
//              let month = component.month?.description,
//              let day = component.day?.description
//        else {
//            let date = Date()
//            return dateText(date: date)
//        }
        let str = formatter.string(from: date)
        return str
    }
    
    func getMonthText(date: Date?) -> String {
        guard let date else { return "" }
        return DateViewModel.calendar.component(.month, from: date).description
    }
    
    func getDayText(date: Date?) -> String {
        guard let date else { return "" }
        return DateViewModel.calendar.component(.day, from: date).description
    }
    
    func getHourText(date: Date?) -> String {
        guard let date else { return "" }
        formatter.dateFormat = "HH"
        
        return formatter.string(from: date)
//        return DateViewModel.calendar.component(.hour, from: date).description
    }
    
    func getMinuteText(date: Date?) -> String {
        guard let date else { return "" }
        formatter.dateFormat = "mm"
        
        return formatter.string(from: date)
    }
    
    
    
    func getYearText(date: Date?) -> String {
        guard let date else { return "" }
        return DateViewModel.calendar.component(.year, from: date).description
    }
    
    func getYearNumber(date: Date?) -> Int {
        guard let date else { return 2023 }
        return DateViewModel.calendar.component(.year, from: date)
    }
    
    func getMonthNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.month, from: date)
    }
    
    func getDayNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.day, from: date)
    }
    
    func getSecondNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.second, from: date)
    }
}
