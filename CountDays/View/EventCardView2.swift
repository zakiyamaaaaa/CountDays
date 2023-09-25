//
//  EventCardView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI

class EventCardViewModel2: ObservableObject {
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

struct EventCardView2: View {
    var event: Event? = nil
    @StateObject var eventVM: EventCardViewModel2
    var displayStyle: EventDisplayStyle? = nil
    
    let width = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        TimelineView(.periodic(from: eventVM.selectedDate, by: 1)) { timeline in
            ZStack {
                
                Rectangle()
                    .foregroundStyle(eventVM.backgroundColor.color ?? .white)
//                    .foregroundColor(eventVM.backgroundColor.color)
                    .widgetFrame()
                    .cornerRadius(30)
                
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
    
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
            calendar.locale = .init(identifier: "ja_JP")
            return calendar
        }()
    
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
            
            let dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
            
            let relative1 = calendar.date(byAdding: .day, value: dateComponent.day!, to: date)!
            let relative2 = calendar.date(byAdding: .month, value: dateComponent.month!, to: relative1)!
            let relative3 = calendar.date(byAdding: .year, value: dateComponent.year!, to: relative2)!
            
            /// カウントダウンが終了した場合
            if second < 0 && eventType == .countdown && frequentType == .never {
                
                HStackLayout(alignment: .center) {
                    Text(displayLang.finishText)
                    Image(systemName: "checkmark.circle.fill")
                }
                
                
                Text(CalendarViewModel.getFormattedDate(eventVM.selectedDate))
                    .padding(.top, 1)
                
                
            } else if abs(day) > 0 {
                Text(day.description + displayLang.dateText.day)
                    .font(.system(.title))
                    .fontWeight(.semibold)
                
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
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            
            VStack(alignment: .leading) {
                Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                    .padding(.vertical, 10)
                Spacer()

                standardTimeView

            }
            .foregroundColor(eventVM.textColor.color)
            .padding()
            .widgetFrame()
            .widgetBackground(eventVM.backgroundColor.color)
            
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
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                VStack {
                    Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                        .foregroundColor(eventVM.textColor.color)
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
                
            }
        }
    }
    
    private var calendarView: some View {
        ZStack {
            
            
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
                        .frame(width: 152, height: 25)
                    Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                        .foregroundColor(eventVM.textColor.color)
                }
                
                ZStack {
                    if eventVM.backgroundColor == .none, let image = eventVM.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .widgetFrame()
                        //                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        Rectangle()
                            .foregroundColor(eventVM.backgroundColor.color)
                            .frame(width: 150, height: 130)
                    }
                        
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
                }
            }
            .foregroundColor(eventVM.textColor.color)
            .cornerRadius(30)
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
        EventCardView2(eventVM: vm)
        EventCardView2(eventVM: vm, displayStyle: .circle)
        EventCardView2(eventVM: vm, displayStyle: .calendar)
        
    }
}
