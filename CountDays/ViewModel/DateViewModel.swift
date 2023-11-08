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
//        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        cal.locale = Locale.current
        return cal
    }()
    
    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale.current
        #if DEBUG
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        #else
        formatter.timeZone = TimeZone.current
        #endif
        return formatter
    }()
    
//    func dateText(date: Date)-> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ja")
//        dateFormatter.dateStyle = .medium
//        let text = dateFormatter.string(from: date)
//        return text
//    }
    
    func dateText(component: DateComponents?) -> String {
        guard let component,
              let year = component.year?.description,
              let month = component.month?.description,
              let day = component.day?.description
        else {
            let date = Date()
            return dateText(date: date)
        }
        return "\(year)/\(month)/\(day)"
    }
    
    func dateText(date: Date?) -> String {
        guard let date else {
            return "no data"
        }
        
        formatter.dateFormat = "yyyy'/'M'/'d'"
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
    
    func getHourAndMinuteText(date: Date?) -> String {
        guard let date else { return "" }
        formatter.dateFormat = "H:mm"
        
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
    
    func getHourNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.hour, from: date)
    }
    
    func getMinuteNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.minute, from: date)
    }
    
    func getSecondNumber(date: Date?) -> Int {
        guard let date else { return 1 }
        return DateViewModel.calendar.component(.second, from: date)
    }
}
