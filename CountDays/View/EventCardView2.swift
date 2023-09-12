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
                    .foregroundColor(eventVM.backgroundColor.color)
                    .frame(width: 150, height: 150)
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
                    
//                switch eventVM.style {
//                case .standard:
//                    standardView
//                case .circle:
//                    circleView
//                case .calendar:
//                    calendarView
//                }
            }
        }
    }
    
    private var standardView: some View {
        ZStack {
            let date = eventVM.selectedDate
            let frequentType = eventVM.frequentType
            let eventType = eventVM.eventType
            let displayLang = eventVM.displayLang
            
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
            let dayText = displayLang.dateText.day
            let hourText = displayLang.dateText.hour
            let minuteText = displayLang.dateText.minute
            let secondText = displayLang.dateText.second
            
            
            if eventVM.backgroundColor == .none, let image = eventVM.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            

            VStack(alignment: .leading) {
                Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                    .padding(.vertical, 10)
                Spacer()

                if second < 0 && eventType == .countdown && frequentType == .never {
                    HStackLayout(alignment: .center) {
                        Text(displayLang.finishText)

                        Image(systemName: "checkmark.circle.fill")
                    }
                    Spacer()
                } else {
                    Text(day.description + dayText)
                        .font(.system(size: 30))
                    HStack() {

                        Text(hour.description + hourText)
                            .isHidden(hidden: !eventVM.showHour)
                        Text(minute.description + minuteText)
                            .isHidden(hidden: !eventVM.showMinute)

                    }

                    Text(second.description + secondText)
                        .isHidden(hidden: !eventVM.showSecond)
                }

            }
            .foregroundColor(eventVM.textColor.color)
            .frame(width: width*1/3, height: width*1/3)
            .padding()
        }
    }
    
    private var circleView: some View {
        VStack {
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
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                VStack {
                    Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
                        .foregroundColor(eventVM.textColor.color)
                    ZStack {
                        
                        
                        Circle()
                            .stroke(
                                Color.pink.opacity(0.5),
                                lineWidth: 10
                            )
                        Circle()
                            .trim(from: 0, to: 0.25)
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
                            .frame(width: 150, height: 150)
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
//    var body: some View {
//        ZStack {
////            Text(event?.title ?? "イベント名")
//            Rectangle()
//                .foregroundColor(.mint)
//            Text(eventVM.text.isEmpty ? "イベント名" : eventVM.text)
//        }
//    }
}

struct EventCardView2_Previews: PreviewProvider {
//    var event = EventCardViewModel.defaultStatus
    static var previews: some View {
        var event = EventCardViewModel.defaultStatus
        let vm = EventCardViewModel2(event: event)
        EventCardView2(eventVM: vm)
//        event.displayStyle = .circle
        EventCardView2(eventVM: vm, displayStyle: .circle)
        EventCardView2(eventVM: vm, displayStyle: .calendar)
//        event.displayStyle = .calendar
//        EventCardView2(eventVM: vm)
//        EventCardView2(event: event, viewModel: vm)
//        let event = EventCardViewModel.defaultStatus
//        EventCardView(event: event, title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .calendar, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
        
//        EventCardView(title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .standard, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
//
//        EventCardView(title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .circle, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
        
    }
}
