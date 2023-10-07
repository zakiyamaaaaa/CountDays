//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by shoichiyamazaki on 2023/09/20.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct Provider: IntentTimelineProvider {
    /// 初めてWidgetを表示するときの設定
    func placeholder(in context: Context) -> SimpleEntry {
        let event = RealmViewModel().events.first ?? EventCardViewModel.defaultStatus
        return SimpleEntry(date: Date(), event: event, configuration: ConfigurationIntent())
    }

    ///タイムラインを取得する前の初期状態。placeholderとあまり違いがわからない
    /// widget galleryに表示される
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let event = RealmViewModel().events.first ?? EventCardViewModel.defaultStatus
        let entry = SimpleEntry(date: Date(), event: event, configuration: configuration)
            
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        let event: Event
        
        if let indexText = configuration.eventPara?.identifier, let index = Int(indexText) {
            event = RealmViewModel().events[index]
            
        } else if RealmViewModel().events.first != nil {
            event = RealmViewModel().events.first!
        } else {
            event = EventCardViewModel.defaultStatus
        }
        
        let nextDate = Calendar.current.nextDate(after: currentDate, matching: .init(minute: 0, second: 1), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) ?? Date()
        
        entries.append(SimpleEntry(date: currentDate, event: event, configuration: configuration))
        
//        for i in 0..<24 {
//            let a = Calendar.current.date(byAdding: .hour, value: i, to: nextDate)!
//            let nextHour = (Calendar.current.dateComponents([.hour], from: nextDate).hour! + i)%24
//            let updateDate = Calendar.current.date(bySettingHour: nextHour, minute: 0, second: 1, of: currentDate) ?? Date()
//            let entry = SimpleEntry(date: updateDate, event: event, configuration: configuration)
//            entries.append(entry)
//        }
        
        for i in 0..<64 {
            //                let a = Calendar.current.date(byAdding: .hour, value: i, to: nextDate)!
            let nextHour = Calendar.current.dateComponents([.hour], from: nextDate).hour!
            let updateDate = Calendar.current.date(bySettingHour: nextHour, minute: 0, second: 5, of: currentDate) ?? Date()
            
            //                Text(updateDate.description)
            
            let updateDate2 = Calendar.current.date(byAdding: .hour, value: i, to: updateDate, wrappingComponents: false)!
            
            let entry = SimpleEntry(date: updateDate2, event: event, configuration: configuration)
            entries.append(entry)
            
            
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
       completion(timeline)
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: Event
    let configuration: ConfigurationIntent
}

struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        
        ZStack(alignment: .bottomTrailing, content: {
            
            if RealmViewModel().events.count > 1 {
                let eventVM = EventCardViewModel2(event: entry.event)
                ZStack {
                    EventCardView2(event: entry.event, eventVM:eventVM, isWidget: true, currentDate: entry.date)
                        .widgetBackground(eventVM.backgroundColor.gradient)
                        
                }
            } else if let event = RealmViewModel().events.first {
                let eventVM = EventCardViewModel2(event: event)
                ZStack {
                    EventCardView2(event: event, eventVM:eventVM, isWidget: true, currentDate: entry.date)
                    
                        
                }
            } else {
                WidgetNoEvent()
            }
            
        })
        
    }
}

struct WidgetNoEvent: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Text("CountDays")
                    .font(.system(size: 16))
                    .padding(.bottom,3)
                    .fontWeight(.bold)
                Image(.iconForWidget)
                    .resizable()
                    .frame(width: 40, height: 40)
                
            }
            Text("アプリでイベントを設定するとウィジェットに反映されます")
                .font(.system(size: 15))
        }
        .widgetBackground(Color.mint)
    }
}

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("ウィジェット")
        .description("ホーム画面にウィジェットを追加できます")
        .supportedFamilies([.systemSmall])
    }
}

struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        let event = EventCardViewModel.defaultStatus
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date(), event: event, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetNoEvent()
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *), #available(iOS 17.0, *) {
            
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
