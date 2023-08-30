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
    var textColor: TextColor
    var showHour: Bool = true
    var showMinute: Bool = true
    var showSecond: Bool = false
    var frequentType: FrequentType
    var eventType: EventType = .countup
    let width = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimelineView(.periodic(from: date, by: 1)) { timeline in
            ZStack {
                
                let day = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).days
                let hour = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).hours
                let minute = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).minutes
                let second = CalendarViewModel.getDates(target: date, eventType: eventType, frequentType: frequentType).seconds
                
                Rectangle()
                    .foregroundColor(backgroundColor.color)
                    .frame(width: width*1/3 + 10, height: width*1/3 + 10)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.white, lineWidth: 3)
                    )
                
                switch style {
                case .standard:
                    VStack(alignment: .leading) {
                        Text(title)
                            .padding(.vertical, 10)
                        Spacer()
                        
                        if second < 0 && eventType == .countdown && frequentType == .never {
                            HStackLayout(alignment: .center) {
                                Text("終了")
                                
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Spacer()
                        } else {
                            Text("\(day)日")
                                .font(.system(size: 30))
                            HStack() {
                                
                                Text("\(hour)時間")
                                    .isHidden(hidden: !showHour)
                                Text("\(minute)分")
                                    .isHidden(hidden: !showMinute)
                                
                            }
                            
                            Text("\(second)秒")
                                .isHidden(hidden: !showSecond)
                        }
                        
                    }
                    .foregroundColor(textColor.color)
                    .frame(width: width*1/3, height: width*1/3)
                    .padding()
                case .circle:
                    VStack {
                        Text(title)
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
                                    Text("終了")
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Text("\(day)")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                    Text("日")
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
    }
}

struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(title: "sanoke1", date: EventCardViewModel.defaultStatus.date, style: .standard, backgroundColor: .primary, textColor: .white, showSecond: true, frequentType: .annual, eventType: .countdown)
    }
}
