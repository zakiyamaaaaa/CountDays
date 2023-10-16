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
    private var standardTimeView2: some View {
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
                
                Text((day*c).formatted() + displayLang.dateText.day)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(relativeDate2, style: .relative)
                    .environment(\.calendar, calendar)
            } else if abs(hour) > 0 {
                
                Text((hour*c).formatted() + displayLang.dateText.hour)
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                let relativeDate2 = Date(timeInterval: relativeInterval - day*Double(secondsOfDay) - hour*Double(secondsOfHour), since: currentDate)
                Text(relativeDate2, style: .relative)
                    .environment(\.calendar, calendar)
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
    
    private var standardTimeView: some View {
        VStack(alignment: .leading) {
            let frequentType = eventVM.frequentType
            let eventType = eventVM.eventType
            let date =  CalendarViewModel.getDates(target: eventVM.selectedDate, eventType: eventType, frequentType: frequentType , dayOfWeek: eventVM.dayOfWeek ).fixedDate
            let displayLang = eventVM.displayLang
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType , dayOfWeek: eventVM.dayOfWeek ).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType, dayOfWeek: eventVM.dayOfWeek).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType, dayOfWeek: eventVM.dayOfWeek).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType, dayOfWeek: eventVM.dayOfWeek).seconds
            let calendar = getCalendar()
            let dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
            
            let relative1 = calendar.date(byAdding: .day, value: dateComponent.day!, to: date)!
            let relative2 = calendar.date(byAdding: .month, value: dateComponent.month!, to: relative1)!
            let relative3 = calendar.date(byAdding: .year, value: dateComponent.year!, to: relative2)!
            
            /// カウントダウンが終了した場合
            if second < 0 && eventType == .countdown && frequentType == .never {
                
                HStackLayout(alignment: .center) {
                    Text(displayLang.finishText)
                        .fontWeight(.bold)
                    Image(systemName: "checkmark.circle.fill")
                }
                
                
                Text(CalendarViewModel.getFormattedDate(eventVM.selectedDate))
                    .padding(.top, 1)
                
                
            } else if abs(day) > 0 {
                
                Text(day.description + displayLang.dateText.day)
                    .font(.system(.largeTitle))
                    .fontWeight(.bold)
                
                Text(relative3, style: .relative)
                    .environment(\.calendar, calendar)
            } else if abs(hour) > 0 {
                let relative4 = calendar.date(byAdding: .hour, value: dateComponent.hour!, to: relative3)!
                Text(hour.description + displayLang.dateText.hour)
                    .font(.system(.title))
                    .fontWeight(.semibold)
                
                Text(relative4, style: .relative)
                    .environment(\.calendar, calendar)
            } else if abs(minute) > 0 {
                Text(relative3, style: .relative)
                    .font(.system(.title2))
                    .fontWeight(.semibold)
                    .environment(\.calendar, calendar)
            } else if second >= 0 {
                Text(relative3, style: .timer)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            } else if second < 0 {
                Text("0...")
            }
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
                standardTimeView2

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
            
            
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
            
            
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
                                Color.pink.opacity(0.5),
                                lineWidth: 10
                            )
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.pink,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                        
                        VStack {
                            if second < 0 && eventType == .countdown && frequentType == .never {
                                Text(displayLang.finishText)
                                
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Text("\(day)")
                                    .font(.system(size: 30))
                                    .fontWeight(.bold)
                                Text(displayLang.dateText.day)
                            }
                        }
                        .rotationEffect(.degrees(90))
                        .foregroundColor(eventVM.textColor.color)
                    }
                    .frame(width: width/5)
                    .rotationEffect(.degrees(-90))
                }
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
                    .frame(width: WidgetConfig.small.size.width, height: WidgetConfig.small.size.height*3/4)
            }
            
            VStack(spacing: 0) {
                let date = eventVM.selectedDate
                let frequentType = eventVM.frequentType
                let eventType = eventVM.eventType
                let displayLang = eventVM.displayLang
                
                let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
                let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
                let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
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
                
                
                    
                        
                VStack {
                    if second < 0 && eventType == .countdown && frequentType == .never {
                        Text(displayLang.finishText)
                        
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Text("\(day)")
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                        Text(displayLang.dateText.day)
                            .font(.system(size: 20))
                    }
                }
                Spacer()
            }
            .widgetFrame()
            .foregroundColor(eventVM.textColor.color)
            .cornerRadius(cornerRadius)
            .compositingGroup()
            .shadow(radius: 3, x:3, y:5)
        }
    }
}

struct EventCardView2_Previews: PreviewProvider {
//    var event = EventCardViewModel.defaultStatus
    static var previews: some View {
        
        let event = EventCardViewModel.defaultStatus
        let vm = EventCardViewModel2(event: event)
        EventCardView2(event: event, eventVM: vm)
        EventCardView2(event: event, eventVM: vm, displayStyle: .circle)
        EventCardView2(event: event, eventVM: vm, displayStyle: .calendar)
        
        
    }
}
