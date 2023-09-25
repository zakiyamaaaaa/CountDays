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
        let event = EventCardViewModel.defaultStatus
        return SimpleEntry(date: Date(), event: event, configuration: ConfigurationIntent())
    }

    ///タイムラインを取得する前の初期状態。placeholderとあまり違いがわからない
    /// widget galleryに表示される
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let event = EventCardViewModel.defaultStatus
        let entry = SimpleEntry(date: Date(), event: event, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        if let event = RealmViewModel().events.first {
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, event: event, configuration: configuration)
                entries.append(entry)
            }
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
        let eventVM = EventCardViewModel2(event: entry.event)
        
        EventCardView2(eventVM: eventVM)
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
