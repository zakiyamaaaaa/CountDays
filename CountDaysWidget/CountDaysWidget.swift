//
//  CountDaysWidget.swift
//  CountDaysWidget
//
//  Created by shoichiyamazaki on 2023/08/24.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
//    private let mockModel = EventModel(title: "Sample Event", date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(), textColor: .white, backgroundColor: .secondary, displayStyle: .standard)
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        let entries = [SimpleEntry(date: tenDaysAgo, configuration: configuration)]

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CountDaysWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
//        let startComponents = DateComponents(year: 2023,month: 6,day: 2)
        let startDate = mockEventModel.date
        let day = CalendarViewModel.getDay(to: startDate)
        let hour = CalendarViewModel.getHour(to: startDate)
        
        VStack(alignment: .leading) {
            HStack {
                Text(mockEventModel.title)
                    .foregroundColor(mockEventModel.textColor)
                Spacer()
            }.padding(.top)
            
            Spacer()
            Text("\(day?.description ?? "aaa")日")
                .font(.system(size: 27))
            Text("\(hour?.description ?? "aaa")時間")
                .padding(.bottom)
        }.padding(.leading)
        
        
    }
}

struct CountDaysWidget: Widget {
    let kind: String = "CountDaysWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CountDaysWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(mockEventModel.backgroundColor)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CountDaysWidget_Previews: PreviewProvider {
    static var previews: some View {
        CountDaysWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
