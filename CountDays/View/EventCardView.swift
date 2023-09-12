//
//  EventCardView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI

struct EventCardView: View {
    var title: String
    var date: Date
    var style: EventDisplayStyle
    var backgroundColor: BackgroundColor
    var image: UIImage?
    var textColor: TextColor
    var showHour: Bool = true
    var showMinute: Bool = true
    var showSecond: Bool = false
    var displayLang: DisplayLang = .jp
    var frequentType: FrequentType
    var eventType: EventType = .countup
    let width = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimelineView(.periodic(from: date, by: 1)) { timeline in
            ZStack {
                
                Rectangle()
                    .foregroundColor(backgroundColor.color)
                    .frame(width: 150, height: 150)
                    .cornerRadius(30)
                
                switch style {
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
    
    private var standardView: some View {
        ZStack {
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
            let dayText = displayLang.dateText.day
            let hourText = displayLang.dateText.hour
            let minuteText = displayLang.dateText.minute
            let secondText = displayLang.dateText.second
            
            
            if backgroundColor == .none, let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            

            VStack(alignment: .leading) {
//                if let event {
//                    Text(event.title)
//                        .foregroundColor(.white)
//                }
                Text(title.isEmpty ? "イベント名" : title)
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
                            .isHidden(hidden: !showHour)
                        Text(minute.description + minuteText)
                            .isHidden(hidden: !showMinute)

                    }

                    Text(second.description + secondText)
                        .isHidden(hidden: !showSecond)
                }

            }
            .foregroundColor(textColor.color)
            .frame(width: width*1/3, height: width*1/3)
            .padding()
        }
    }
    
    private var circleView: some View {
        VStack {
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
            
            let dayText = displayLang.dateText.day
            let hourText = displayLang.dateText.hour
            let minuteText = displayLang.dateText.minute
            let secondText = displayLang.dateText.second
            ZStack {
                if backgroundColor == .none, let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                VStack {
                    Text(title.isEmpty ? "イベント名" : title)
                        .foregroundColor(textColor.color)
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
                        .foregroundColor(textColor.color)
                    }
                    .frame(width: width/5)
                    .rotationEffect(.degrees(-90))
                }
            }
        }
    }
    
    private var calendarView: some View {
        VStack(spacing: 0) {
            let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
            let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
            let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
            let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
            
            let dayText = displayLang.dateText.day
            let hourText = displayLang.dateText.hour
            let minuteText = displayLang.dateText.minute
            let secondText = displayLang.dateText.second
            
            ZStack {
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 152, height: 25)
                Text(title.isEmpty ? "イベント名" : title)
                    .foregroundColor(textColor.color)
            }
            
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 150, height: 130)
                
                if backgroundColor == .none, let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
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
        .cornerRadius(30)
        .compositingGroup()
        .shadow(radius: 3, x:3, y:5)
    }
}

struct EventCardView_Previews: PreviewProvider {
//    var event = EventCardViewModel.defaultStatus
    static var previews: some View {
        let event = EventCardViewModel.defaultStatus
//        EventCardView(event: event, title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .calendar, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
//        
//        EventCardView(title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .standard, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
//        
//        EventCardView(title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .circle, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
        
    }
}
