
//  ConfigureEventView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/16.
//

import SwiftUI
import RealmSwift

struct ConfigureEventView: View {
    
    /// 毎年のイベントの場合、どのようにDateを処理すればいいか
    /// FrequentTypeによって日にちのカウント方法を変更する
    /// .annualの場合、365のあまり、もしくは
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName = ""
    @State private var isShowSheet = false
    @State private var isFirstButtonSelected = true
    @State private var isSecondButtonSelected = false
    @State private var isThirdButtonSelected = false
    @State private var isFourthButtonSelected = false
    @State private var focusButton = false
    @State var selectedStyleIndex = 0
    @State var selectedBackgroundColor: BackgroundColor = .primary
    @State var selectedTextColor: TextColor = .white
    @State private var isTrashAnimation = false
    @State private var showDeleteAlert = false
    @FocusState private var focusField: Bool
    private let initialEventName = EventCardViewModel.defaultStatus.title
    @ObservedObject var realmMock: RealmMockStore
    @Binding var event: Event
    let isCreation: Bool
    
    /// Realmの配列を受け取ってそれを削除する方法
//    @ObservedRealmObject var selectedEvent: Event
    
    @State var eventDate: Date = Date()
    @State var eventTitle: String = ""
    @State var showStyleDetailConfiguration = false
    @State var showHour = true
    @State var showMinute = true
    @State var showSecond = false
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @StateObject var dateViewModel = DateViewModel()
    @State var frequentType: FrequentType = .never
    @State var eventType: EventType = .countup
    @State var dayOfWeek: DayOfWeek = .sunday
    var selectedStyle: EventDisplayStyle = .standard
    private let bgColorList: [BackgroundColor] = BackgroundColor.allCases
    private let txtColorList: [TextColor] = TextColor.allCases
    @State var positionX = -10
     var positionY = 0
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                headerView
                
                VStack {
                    
                    HStack {
                        Button("Sサイズ") {
                            
                        }
                        Button("Mサイズ") {
                            
                        }
                    }
                    .hidden()
                    
                    let date = dateViewModel.selectedDate
                    
                     ZStack {
                         EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: EventDisplayStyle(rawValue: selectedStyleIndex)!, backgroundColor: selectedBackgroundColor, textColor: selectedTextColor, showHour: showHour, showMinute: showMinute, showSecond: showSecond, frequentType: frequentType, eventType: eventType)
//                         EventCardView(title: eventTitle.isEmpty ? "イベント名" : eventTitle, day: day ?? 1, hour: hour ?? 111, minute: minute ?? 111, style: EventDisplayStyle(rawValue: selectedStyleIndex)!, backgroundColor: selectedBackgroundColor, textColor: selectedTextColor)
                         Button {
                             self.showDeleteAlert.toggle()
                         } label: {
                             Image(systemName: "trash.fill")
                         }
                         .opacity(isCreation ? 0 : 1)
                         .buttonStyle(EventConfigurationButtonStyle(active: $isSecondButtonSelected))
                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                         .padding(.trailing, 10)
                         .offset(x:0, y: isTrashAnimation ? 0 : 100)
                         .animation(.easeIn.delay(0.3), value: isTrashAnimation)
                         .onAppear {
                             self.isTrashAnimation.toggle()
                         }
                         .alert("このイベントを消去しますか？", isPresented: $showDeleteAlert) {
                             Button("キャンセル", role: .cancel) {
                                 
                             }
                             Button("消去", role: .destructive) {
                                 
                                 $event.delete()
                                 // 削除処理
//                                 RealmViewModel().deleteEvent(event: a)
                                 
                                /// 通知の登録削除処理
                                 NotificationCenter.removeNotification(id: event.id.stringValue)
                                
                                 // 画面閉じる
                                 presentationMode.wrappedValue.dismiss()
                             }
                         } message: {
                             Text("一度消去すると元に戻せません")
                         }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.vertical, 20)
                .background(ColorUtility.secondary)
                
                configurationSelectionView
                
                ZStack {
                    if isFirstButtonSelected {
                        eventTitleView
                    }
                    
                    if isSecondButtonSelected {
                        styleView
                    }
                    
                    if isThirdButtonSelected {
                        backgroundColorView
                    }
                    
                    if isFourthButtonSelected {
                        textColorView
                    }
                }
            }
        }
        .onAppear{
        
            print(event.date)
            eventDate = event.date
            dateViewModel.selectedDate = event.date
            showHour = event.displayHour
            showMinute = event.displayMinute
            showSecond = event.displaySecond
//            selectedFrequentType = event.frequentType
//            selectedEventType = event.eventType
        }
    }
    
    /// 設定選択ビュー
    private var configurationSelectionView: some View {
        HStack {
            Spacer()
            Button {
                if !isFirstButtonSelected {
                    isFirstButtonSelected = true
                    isSecondButtonSelected = false
                    isThirdButtonSelected = false
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "calendar")
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isFirstButtonSelected))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isFirstButtonSelected ? Color.red : .clear, lineWidth: 2)
            )
            
            Spacer()
            
            Button {
                if !isSecondButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = true
                    isThirdButtonSelected = false
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "wand.and.stars.inverse")
                    
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isSecondButtonSelected))
            
            
            Spacer()
            Button {
                if !isThirdButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = false
                    isThirdButtonSelected = true
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "paintbrush.fill")
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isThirdButtonSelected))

            
            Spacer()
            
            Button {
                if !isFourthButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = false
                    isThirdButtonSelected = false
                    isFourthButtonSelected = true
                }
            } label: {
                Image(systemName: "textformat")
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isFourthButtonSelected))
            
            Spacer()
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(ColorUtility.primary)
    }
    
    /// HeaderView
    private var headerView: some View {
        HStack {
            Button("✗") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(width: 50, height: 50)
            .foregroundColor(.white)
            .font(.system(size: 30))
            .background(ColorUtility.secondary)
            .clipShape(Circle())
            .padding()

            Spacer()
            Button(isCreation ? "保存" : "更新") {
                
                if eventTitle.isEmpty {
                    /// TODO: イベント名を入力してくださいエラーメッセージ表示
                    return
                }
                let event = Event(title: eventTitle, date: dateViewModel.selectedDate, textColor: selectedTextColor, backgroundColor: selectedBackgroundColor, displayStyle: EventDisplayStyle(rawValue: selectedStyleIndex)!, fontSize: 1.0, dayOfWeek: dayOfWeek, displayHour: showHour, displayMinute: showMinute, displaySecond: showSecond)
                
                switch isCreation {
                    /// 新規作成
                    case true:
                        RealmViewModel().registerEvent(event: event)
                        realmMock.cards.insert(event, at: 0)
                    /// 更新
                    case false:
                        RealmViewModel().updateEvent(event: event)
                }
                NotificationCenter.registerNotification(event: event)
                presentationMode.wrappedValue.dismiss()
            }
            .frame(width: 80, height: 50)
            .font(.system(size: 20))
            .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.highlighted))
            .padding()
        }
        .frame(height: 80)
        .background(ColorUtility.primary)
    }
    
    /// イベントタイトル名編集もしくは日付を設定するボタンを表示するビュー
    private var eventTitleView: some View {
        VStack {
            HStack {
                ZStack(alignment: .leading) {
                    
                    TextField("", text: $eventTitle,
                              onEditingChanged: { editing in
                    })
                    .border(.white)
                    .font(.system(size: 30))
                    .padding()
                    .foregroundColor(.white)
                    .frame(height : 80.0)
                    .background(RoundedRectangle(cornerRadius: 20)
                        .fill(ColorUtility.secondary))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(focusField ? .mint : .clear, lineWidth: 5)
                    )
                    .padding(.vertical, 10)
                    .focused($focusField)
                    
                    if eventTitle.isEmpty {
                        Text("イベント名を入力")
                            .foregroundColor(.gray)
                            .padding(.horizontal,30)
                            .allowsHitTesting(false)
                            
                    }
                }
                
                if focusField {
                    Button {
                        focusField = false
                        
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .padding()
                    .background(focusField ? .mint : .gray)
                    .tint(.white)
                    .clipShape(Circle())
                }
            }.animation(.spring(), value: focusField)
            
            
            Button {
                isShowSheet.toggle()
            } label: {
                HStack {

                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.horizontal)

                        if frequentType != .never {
                            Text("リピート")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .background(Color.red)
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            let date = dateViewModel.selectedDate
                            let year = dateViewModel.getYearText(date: date)
                            let month = dateViewModel.getMonthText(date: date)
                            let day = dateViewModel.getDayText(date: date)
                            switch frequentType {
                            case .never:
//                                Text(dateViewModel.dateText(date: date))
                                Text(year + "/" + month + "/" + day)
                            case .annual:
                                Text("毎年：")
                                Text(month + "月" + day + "日")
                            case .monthly:
                                Text("毎月：")
                                Text(day + "日")
                            case .weekly:
                                Text("毎週：")
                                Text(dayOfWeek.stringValue)
                            }
                        }
                        Text("終日")

                    }
                    .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 80.0)
                .frame(alignment: .leading)
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.highlighted))
            }.sheet(isPresented: $isShowSheet) {
                ConfigureDateView(eventType: $eventType, frequentType: $frequentType, dateViewModel: _dateViewModel, weeklyDate: $dayOfWeek)
                
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    
    @State var number = 0
    /// イベントの表示スタイルを編集するビュー
    ///他のところで使われていないので、ファンクションに切り出す方が良いかも
    private var styleView: some View {
        VStack {
            TabView(selection: $selectedStyleIndex) {
                let date = dateViewModel.selectedDate
                VStack {
                    EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: .standard, backgroundColor: selectedBackgroundColor, textColor: selectedTextColor, showSecond: showSecond, frequentType: frequentType)
                        
                        
                    Button {
                        showStyleDetailConfiguration.toggle()
                    } label: {
                        Text("詳細設定")
                    }
                }
                .tag(0)
                .sheet(isPresented: $showStyleDetailConfiguration) {
                    EventDetailConfigurationView(showHour: $showHour, showMinute: $showMinute, showSecond: $showSecond)
                        .presentationDetents([.medium])
                }
                
                EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: .circle, backgroundColor: selectedBackgroundColor, textColor: selectedTextColor, showSecond: showSecond, frequentType: frequentType)
                    .tag(1)
                
            }
            .onChange(of: selectedStyleIndex, perform: { newValue in
                print(newValue)
            })
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    
    /// 背景色を編集するビュー
    private var backgroundColorView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(bgColorList, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [item.color, item.color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(item == selectedBackgroundColor ? .red : .clear, lineWidth: 2)
                        )
                        .onTapGesture(perform: {
                            selectedBackgroundColor = item
                            print(item.color)
                        })
                        .padding()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    
    /// テキストの色を編集するビュー
    private var textColorView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(txtColorList, id: \.self) { item in
                    
                    Text("Aa")
                        .foregroundColor(item.color)
                        .font(.system(size: 50))
                        .frame(width: 80, height: 80)
                        .border(item == selectedTextColor ?  .red : .clear)
                        .onTapGesture(perform: {
                            selectedTextColor = item
                            print(item.color)
                        })
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
}
    




struct ConfigureEventView_Previews: PreviewProvider {
    @State static var event = EventCardViewModel.defaultStatus
    @State static var eventTitle = ""
    @State static var events = try! Realm().objects(Event.self)
    @State static var date = EventCardViewModel.defaultStatus.date
    static var previews: some View {
        ConfigureEventView(realmMock: RealmMockStore(), event: $event, isCreation: true, eventTitle: eventTitle)
    }
}

extension Color {
    
    func dark(brightnessRatio: CGFloat = 1.6) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        let color = UIColor(self)
    
        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return Color(hue: hue, saturation: saturation*brightnessRatio, brightness: brightness, opacity: alpha)
        }
        return self
    }
}
