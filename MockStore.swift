//
//  MockStore.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import Foundation

//class MockStore: ObservableObject {
//   @Published var cards: [Event] = [
//    
//        EventCard(title: "Event title 1", year: 2023, month:4, day: 1, hour: 2, minute: 3, style: .standard, backgroundColor: .primary, textColor: .white),
//        EventCard(title: "Event title 2", year: 2023, month:4,day: 1, hour: 2, minute: 3, style: .standard, backgroundColor: .primary, textColor: .white),
//        EventCard(title: "Event title 3", year: 2023, month:4,day: 1, hour: 2, minute: 3, style: .standard, backgroundColor: .primary, textColor: .white),
////        EventCard(title: "Event title 4", day: "1", hour: "2", minute: "3", style: .standard, backgroundColor: .primary, textColor: .white),
////        EventCard(title: "Event title 5", day: "1", hour: "2", minute: "3", style: .standard, backgroundColor: .primary, textColor: .white),
//        
//    ]
//}

class RealmMockStore: ObservableObject {
    @Published var cards: [Event] = [
        Event(title: "Test1", date: Date(timeIntervalSinceNow: -60*60*24*1), textColor: .white, backgroundColor: .blue, displayStyle: .standard, fontSize: 1.0),
        Event(title: "Test2", date: Date(timeIntervalSinceNow: -60*60*24*30), textColor: .red, backgroundColor: .blue, displayStyle: .standard, fontSize: 1.0),
        Event(title: "Test3", date: Date(timeIntervalSinceNow: -60*60*24*100), textColor: .blue, backgroundColor: .white, displayStyle: .standard, fontSize: 1.0),
        Event(title: "Test4", date: Date(timeIntervalSinceNow: -60*60*24*100), textColor: .blue, backgroundColor: .white, displayStyle: .standard, fontSize: 1.0)
        ,
        Event(title: "Test4", date: Date(timeIntervalSinceNow: -60*60*24*100), textColor: .blue, backgroundColor: .white, displayStyle: .standard, fontSize: 1.0)
        ,
        Event(title: "Test4", date: Date(timeIntervalSinceNow: -60*60*24*100), textColor: .blue, backgroundColor: .white, displayStyle: .standard, fontSize: 1.0)
    ]
}
