//
//  EventCardViewModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/04.
//

import Foundation

struct EventCardViewModel {
    
    static let defaultStatus = Event(title: "", date:
                                        Date().addingTimeInterval(-160)
//                                        Calendar(identifier: .gregorian).date(from: DateComponents(year: 2023, month: 10, day: 8, hour: 0,minute: 0,second: 0)) ?? Date()
                                     , textColor: .white, backgroundColor: .blue, displayStyle: .standard, fontSize: 1.0, frequentType: .never, eventType: .countdown, dayAtMonthly: 10, dayOfWeek: .thursday)
}
