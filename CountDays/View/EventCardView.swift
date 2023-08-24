//
//  EventCardView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI

struct EventCardView: View {
    var title: String
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var style: EventDisplayStyle
    var backgroundColor: BackgroundColor
    var textColor: TextColor
    var showHour: Bool = true
    var showMinute: Bool = true
    var showSecond: Bool = false
    let width = UIScreen.main.bounds.width
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @State var currentSecond = 20
    
    var body: some View {
        
        ZStack {
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
                    Text("\(day)日")
                        .font(.system(size: 30))
                    HStack() {
                        
                        Text("\(hour)時間")
                            .isHidden(hidden: !showHour)
                        Text("\(minute)分")
                            .isHidden(hidden: !showMinute)
                        
                    }
                    
                    Text("\(currentSecond)秒")
                        .onReceive(timer) { value in
                            currentSecond = DateViewModel().getSecondNumber(date: value)
                        }.isHidden(hidden: !showSecond)
                    
                    
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
                            Text("\(day)")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                            Text("日")
                                
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

struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView(title: "sanoke1", day: 1, hour: 2, minute: 3, second: 20, style: .standard, backgroundColor: .primary, textColor: .white)
    }
}
