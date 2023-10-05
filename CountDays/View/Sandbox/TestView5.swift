//
//  TestView5.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/10/04.
//

import SwiftUI


/// テキストのタイマーあたりをテストする

struct TestView5: View {
    var calendar: Calendar {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .init(identifier: "ja_JP")
        return calendar
    }
    
    var body: some View {
        
        
        let selectedDate = calendar.date(from: DateComponents(year: 2023, month: 10, day: 5, hour: 0,minute: 0,second: 0))!
//        let hourDate = calendar.date(bySetting: .hour, value: <#T##Int#>, of: <#T##Date#>)
        
        Divider()
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text(selectedDate, style: .time)
        Text(selectedDate, style: .date)
            .environment(\.calendar, calendar)
        Text(selectedDate, style: .relative)
            .environment(\.calendar, calendar)
        Text(selectedDate, style: .offset)
            .environment(\.calendar, calendar)
        Text(selectedDate, style: .timer)
            .environment(\.calendar, calendar)
        Text(selectedDate...selectedDate.advanced(by: 60 * 60 * 24))
            .environment(\.calendar, calendar)
//        Text(Date().formatted(date: .abbreviated, time: .omitted), style:.relative)
        Text("")
    }
}

#Preview {
    TestView5()
}
