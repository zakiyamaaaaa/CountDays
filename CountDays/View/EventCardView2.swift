//
//  EventCardView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI
import RealmSwift

class EventCardViewModel2: ObservableObject {
    @Published var event: Event
    @Published var text: String
    @Published var style: EventDisplayStyle
    @Published var date: Date
    @Published var selectedDate: Date = Date(timeIntervalSinceNow: -10000)
    @Published var backgroundColor: BackgroundColor
    @Published var frequentType: FrequentType
    @Published var eventType: EventType = .countup
    @Published var textColor: TextColor
    @Published var displayLang: DisplayLang = .jp
    @Published var showHour = true
    @Published var showMinute = true
    @Published var showSecond = false
    @Published var image: UIImage?
    @Published var fontSize: Float
    @Published var dayOfWeek: DayOfWeek
    @Published var dayOfMonth: Int
    @Published var unitOfCircle: Int
    @Published var createdDate: Date
    @Published var updatedDate: Date
    
    init(event: Event) {
        self.event = event
        self.text = event.title
        self.style = event.displayStyle
        self.date = event.date
        self.backgroundColor = event.backgroundColor
        self.frequentType = event.frequentType
        self.eventType = event.eventType
        self.textColor = event.textColor
        self.displayLang = event.displayLang
        self.image = event.image
        self.selectedDate = event.date
        self.fontSize = event.fontSize
        self.dayOfWeek = event.dayOfWeek
        self.dayOfMonth = event.dayAtMonthly
        self.unitOfCircle = event.unitOfCircle
        self.createdDate = event.createdDate
        self.updatedDate = event.updatedDate
    }
}

struct EventCardView3: View {
    @ObservedRealmObject var event: Event
    
    var body: some View {
        VStack {
            Text($event.title.wrappedValue)
        }
    }
}

struct EventCardView2: View {

    @ObservedRealmObject var event: Event
    let eventVM: EventCardViewModel2
    var displayStyle: EventDisplayStyle? = nil
    var isWidget = false
    
    let width = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    private let cornerRadius: CGFloat = 22
    var currentDate = Date()

    var body: some View {
        TimelineView(.periodic(from: eventVM.selectedDate, by: 1)) { timeline in
            ZStack {
                
                Rectangle()
                    .foregroundStyle(
                        eventVM.backgroundColor.gradient ?? LinearGradient(colors: [], startPoint: UnitPoint(), endPoint: UnitPoint())
                        )
                    .widgetFrame()
                    .cornerRadius(cornerRadius)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(ColorUtility.highlighted, lineWidth: 0.5)

                    })
                    
                
                if let displayStyle {
                    switch displayStyle {
                    case .standard:
                        standardView
                    case .circle:
                        circleView
                    case .calendar:
                        calendarView
                    }
            
                } else {
                    switch eventVM.style {
                    case .standard:
                        standardView
                    case .circle:
                        circleView
                    case .calendar:
                        calendarView
                    }
                }
            }
        }
    }
    
    private func getCalendar()-> Calendar {
        switch eventVM.displayLang {
        case .en:
            var calendar = Calendar(identifier: .gregorian)
                calendar.locale = .init(identifier: "en_US")
            return calendar
        case .jp:
            var calendar = Calendar(identifier: .gregorian)
                calendar.locale = .init(identifier: "ja_JP")
            return calendar
        }
    }
    private let secondsOfDay = 60*60*24
    private let secondsOfHour = 60*60
    private let secondsOfMinute = 60
    
    /// countdownでしか使えない
    /// 改善点、currentDateから最新のDateを引っ張ってくるので、Widgetが更新される
    private var TimeView2: some View {
        VStack(alignment: .leading, content: {
            
            let target = getTargetDate(type: eventVM.frequentType)
            let calendar = getCalendar()
            let relativeInterval = target.timeIntervalSince(currentDate)
            
            var day = Double(Int(relativeInterval)/secondsOfDay)
            let hour = Double(Int(Int(relativeInterval)%secondsOfDay)/secondsOfHour)
            let minute = Double(Int(Int(relativeInterval)%secondsOfHour)/secondsOfMinute)
            let second = Int(relativeInterval)%secondsOfMinute

            let relativeDate2 = Date(timeInterval: relativeInterval - day*Double(secondsOfDay), since: currentDate)
            let displayLang = eventVM.displayLang
            let c: Double = eventVM.eventType == .countup ? -1 : 1
            /// カウントダウンが終了した場合
            if eventVM.eventType == .countdown && eventVM.frequentType == .never && relativeInterval < 0 {
                
                
                HStackLayout(alignment: .center) {
                    Text(displayLang.finishText)
                        .fontWeight(.bold)
                    Image(systemName: "checkmark.circle.fill")
                }
                
                
                Text(CalendarViewModel.getFormattedDate(eventVM.selectedDate))
                    .padding(.top, 1)
                
            } else if abs(day) > 0 {
                
                switch eventVM.style {
                case .standard:
                    Text((day*c).formatted() + displayLang.dateText.day)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Text(relativeDate2, style: .relative)
                        .environment(\.calendar, calendar)
                case .circle, .calendar:
                    VStack(alignment: .center) {
                        Text((day*c).formatted())
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text(displayLang.dateText.day)
                            .fontWeight(.semibold)
                            .environment(\.calendar, calendar)
                    }
                }
                
                    
            } else if abs(hour) > 0 {
                switch eventVM.style {
                case .standard:
                    Text((hour*c).formatted() + displayLang.dateText.hour)
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    let relativeDate2 = Date(timeInterval: relativeInterval - day*Double(secondsOfDay) - hour*Double(secondsOfHour), since: currentDate)
                    Text(relativeDate2, style: .relative)
                        .environment(\.calendar, calendar)
                case .circle, .calendar:
                    VStack(alignment: .center) {
                        Text((hour*c).formatted())
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text(displayLang.dateText.hour)
                            .fontWeight(.semibold)
                            .environment(\.calendar, calendar)
                    }
                }
                
            } else if abs(minute) > 0 {
                    Text(relativeDate2, style: .relative)
                        .font(.largeTitle)
                        .environment(\.calendar, calendar)
                        .fontWeight(.semibold)
                    
                
            } else if abs(second) >= 0 {
                Text(relativeDate2, style: .timer)
                    .font(.largeTitle)
                    .environment(\.calendar, calendar)
                    .fontWeight(.semibold)
            } 
//            else if second < 0 {
//                Text("0...")
//                    .font(.largeTitle)
//                    .fontWeight(.semibold)
//            }
        })
    }
    
    private func getTargetDate(type: FrequentType) -> Date {
        let target = eventVM.selectedDate
        let calendar = getCalendar()
        let month = calendar.component(.month, from: target)
        let day = calendar.component(.day, from: target)
        let hour = calendar.component(.hour, from: target)
        let minute = calendar.component(.minute, from: target)
        let weekday = calendar.component(.weekday, from: target)
        switch type {
        case .never:
            return target
        case .annual:
            return calendar.nextDate(after: currentDate, matching: .init(month: month, day: day ,hour: hour, minute: minute), matchingPolicy: .nextTime) ?? Date()
        case .monthly:
            return calendar.nextDate(after: currentDate, matching: .init(day: day ,hour: hour, minute: minute), matchingPolicy: .nextTime) ?? Date()
        case .weekly:
            return calendar.nextDate(after: currentDate, matching: .init(hour: hour, minute: minute, weekday: weekday), matchingPolicy: .nextTime) ?? Date()
        }
    }
    
    private var standardView: some View {
        ZStack {
            
            if eventVM.backgroundColor == .none, let image = eventVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .widgetFrame()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            
            
            VStack(alignment: .leading) {
                Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                    .fontWeight(.semibold)
                    .font(.system(size: 13))
                    .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                Spacer()
                TimeView2

            }
            .foregroundColor(eventVM.textColor.color)
            .padding()
            .widgetFrame(alignment: .leading)
            
            if isWidget {
                Image(.iconForWidget)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(5)
                    .widgetFrame(alignment: .bottomTrailing)
            }
//            .widgetBackground(eventVM.backgroundColor.color)
        }
    }
    
    /// MARK :- サークルビューに使用するバーの進捗率
    /// 0.0 ~ 1.0
    private func progressRatio(viewModel: EventCardViewModel2) -> CGFloat {
        guard let remainSecond = CalendarViewModel.getRemainSecond(target: viewModel.selectedDate, eventType: viewModel.eventType, frequentType: viewModel.frequentType) else { return 0}
        switch viewModel.eventType {
        case .countup:
            return CGFloat(remainSecond)/CGFloat(24*60*60*100)
        case .countdown:
            switch viewModel.frequentType {
            case .never:
                /// 今の残り秒数/当初の残り秒数
                guard let initialSecond = CalendarViewModel.getRemainSecond(target: viewModel.selectedDate, updatedDate: viewModel.updatedDate, eventType: viewModel.eventType, frequentType: viewModel.frequentType) else { return 0 }
                
                return 1 - CGFloat(remainSecond)/CGFloat(initialSecond)
            case .annual:
                return 1 - (CGFloat(remainSecond)/CGFloat(24*60*60*365))
            case .monthly:
                /// １ヶ月を基準
                let daysOfMonth = CalendarViewModel.getLastDayOfMonth()
                
                return 1 -  (CGFloat(remainSecond)/CGFloat(24*60*60*daysOfMonth))
            case .weekly:
                /// １週間を基準
                return 1 - (CGFloat(remainSecond)/CGFloat(24*60*60*7))
            }
        }
    }
    
    private var circleView: some View {
        VStack(spacing: 0) {
            let date = eventVM.selectedDate
            let frequentType = eventVM.frequentType
            let eventType = eventVM.eventType
            let displayLang = eventVM.displayLang
            
            ZStack {
                if eventVM.backgroundColor == .none, let image = eventVM.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .widgetFrame()
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                VStack {
                    Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                        .foregroundColor(eventVM.textColor.color)
                        .fontWeight(.semibold)
                        .font(.system(size: 13))
                        .frame(width: WidgetConfig.small.size.width)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        
                    ZStack {
                        
                        let progress = progressRatio(viewModel: eventVM)
                        
                        let _ = print("Progress:\(progress)")
                        Circle()
                            .stroke(
                                Color.white.opacity(0.5),
                                lineWidth: 10
                            )
                        Circle()
                            .stroke(
                                Color.pink.opacity(0.3),
                                lineWidth: 10
                            )
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.pink,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                        
                        VStack {
                            if currentDate > eventVM.selectedDate && eventType == .countdown && frequentType == .never {
                                Text(displayLang.finishText)
                                    .fontWeight(.semibold)
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                TimeView2
                            }
                        }
                        .rotationEffect(.degrees(90))
                    }
                    .frame(width: width/5)
                    .rotationEffect(.degrees(-90))
                    
                    if currentDate > eventVM.selectedDate && eventType == .countdown && frequentType == .never {
                        Text(CalendarViewModel.getFormattedDate(eventVM.selectedDate))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal)
                            
                    }
                }
                .foregroundStyle(eventVM.textColor.color)
                .widgetFrame()
                
            }
        }
    }
    
    private var calendarView: some View {
        ZStack {
            if eventVM.backgroundColor == .none, let image = eventVM.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: WidgetConfig.small.size.width, height: WidgetConfig.small.size.height)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
            } else {
                Rectangle()
                    .foregroundStyle(eventVM.backgroundColor.color ?? .white)
                    .widgetFrame()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            
            VStack(spacing: 0) {
                let date = eventVM.selectedDate
                let frequentType = eventVM.frequentType
                let eventType = eventVM.eventType
                let displayLang = eventVM.displayLang
                
                let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
                
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: WidgetConfig.small.size.width, height: WidgetConfig.small.size.height/4)
                    Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                        .foregroundColor(eventVM.textColor.color)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .padding(.horizontal)
                        .frame(width: WidgetConfig.small.size.width)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                }
                Spacer()
                
                TimeView2
                
                Spacer()
            }
            .widgetFrame()
            .foregroundColor(eventVM.textColor.color)
            .cornerRadius(cornerRadius)
            .compositingGroup()
        }
    }
}

struct EventCardView2_Previews: PreviewProvider {
//    var event = EventCardViewModel.defaultStatus
    
    private static func getviewmodel(style: EventDisplayStyle)-> EventCardViewModel2{
        let event = EventCardViewModel.defaultStatus
        let vm = EventCardViewModel2(event: event)
        switch style {
        case .standard:
            vm.style = .standard
        case .circle:
            vm.style = .circle
            
        case .calendar:
            vm.style = .calendar
            
        }
        return vm
    }
    
    static var previews: some View {
        
        let event1 = EventCardViewModel.defaultStatus
        let vm = getviewmodel(style: .standard)
        EventCardView2(event: event1, eventVM: vm)
        let vm2 = getviewmodel(style: .circle)
        EventCardView2(event: event1, eventVM: vm2)
        let vm3 = getviewmodel(style: .calendar)
        EventCardView2(event: event1, eventVM: vm3)
        
        
    }
}
