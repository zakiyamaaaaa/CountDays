//
//  EventCardViewModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/04.
//

import Foundation

struct EventCardViewModel {
//    static let defaultStatus = Event(title: "イベント名",year: 2023, month:4, day: 1, hour: 2, minute: 3, style: .standard, backgroundColor: .primary, textColor: .white)
    static let defaultStatus = Event(title: "", date: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2023, month: 9, day: 15, hour: 0)) ?? Date(), textColor: .white, backgroundColor: .primary, displayStyle: .standard, fontSize: 1.0)
    
//    static var defaultDate: Date? {
//        return Calendar(identifier: .gregorian).date(from: DateComponents(year: defaultStatus.year, month: defaultStatus.month, day: defaultStatus.day, hour: defaultStatus.hour))
//    }
}
