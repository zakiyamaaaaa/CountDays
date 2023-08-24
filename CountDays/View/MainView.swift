//
//  MainView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI
import Algorithms
import RealmSwift

struct MainView: View {
    @State private var isShow = false
    @State private var isShowConfigured = false
    @State private var isSettingButton = false
//    @StateObject var mock = MockStore()
    @StateObject var realmMock = RealmMockStore()
//    @StateObject var defaultEvent = EventCardViewModel.defaultStatus
    @EnvironmentObject var viewModel: RealmViewModel
    
    let dateViewModel = DateViewModel()
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
    ]
    let itemPerRow: CGFloat = 5
    let horizontalSpacing: CGFloat = 15
    @ObservedResults(Event.self) var realmCards
    @State var selectedEvent = Event()
    @State var selectedIndex = 0
    var selectedEventStyle: EventDisplayStyle = .standard
    var body: some View {
        VStack {
            HStack {
                Text("ようこそ")
                    .font(.system(size: 35,weight: .bold))
                    .padding()
                Spacer()
                
                Button {
                    isSettingButton.toggle()
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 30,height: 30)
                }
                .padding()
            }
            .foregroundColor(.white)
            .frame(height: 80)
            .background(ColorUtility.secondary)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    
                    ForEach(0 ..< realmCards.count + 1, id: \.self) { i in
                        VStack {
                            if i >= 1 {
                                let card = realmCards[i - 1]
                                
                                let day = CalendarViewModel.getDay(to: card.date)!
                                let hour = CalendarViewModel.getHour(to: card.date)!
                                let minute = CalendarViewModel.getMinute(to: card.date)!
                                let second = CalendarViewModel.getSecond(to: card.date)!
                                EventCardView(title: card.title, day: day, hour: hour, minute: minute, second: second, style: card.displayStyle, backgroundColor: card.backgroundColor, textColor: card.textColor)
                                    .onTapGesture {
                                        isShowConfigured.toggle()
                                        selectedEvent = realmCards[i - 1]
                                        self.selectedIndex = i
                                        let _ = print(i)
                                        let _ = print(selectedEvent.title)
                                    }
                                    

                            } else if i == 0 {
                                AddEventView()
                                    .onTapGesture {
                                        isShow.toggle()
                                        selectedEvent = EventCardViewModel.defaultStatus
                                    }
                                    
                            }
                            
                        }
                    }.sheet(isPresented: $isShowConfigured) {
                        
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: false)
                    }.sheet(isPresented: $isShow) {
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: true)
                    }.sheet(isPresented: $isSettingButton) {
                        SettingView()
                    }
                }
            }
            .background(ColorUtility.backgroundary)
            
            Spacer()
            
            Button {
                
                print("notification request")
                NotificationCenter.sendNotificationRequest()
                
            } label: {
                Text("Notification")
            }
            
        }
        .background(ColorUtility.backgroundary)

    }
}

/// Realmのテスト
///
///

class Todo: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = "aaa"
    @Persisted var status: String = "bbb"
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
