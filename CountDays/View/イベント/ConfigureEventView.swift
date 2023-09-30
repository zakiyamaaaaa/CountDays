
//  ConfigureEventView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/16.
//

import SwiftUI
import StoreKit
import RealmSwift
import Photos
import PhotosUI
import Foundation
import FirebaseAnalytics
import WidgetKit

struct ConfigureEventView: View {
    
    /// 毎年のイベントの場合、どのようにDateを処理すればいいか
    /// FrequentTypeによって日にちのカウント方法を変更する
    /// .annualの場合、365のあまり、もしくは
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: Store
    @State var isPurchased = false
    @State private var isShowSheet = false
    @State private var isFirstButtonSelected = true
    @State private var isSecondButtonSelected = false
    @State private var isThirdButtonSelected = false
    @State private var isFourthButtonSelected = false
    @State private var trashButtonSelected = false
    @State private var focusButton = false
    @State var selectedStyleIndex = 0
    @State var selectingStyleIndex = 0
    @State private var selectedBackgroundStyle: BackgroundStyle = .simple
    @State private var isTrashAnimation = false
    
    @FocusState private var focusField: Bool
    @ObservedObject var realmMock: RealmMockStore
    @Binding var event: Event
    let isCreation: Bool
    
    /// Realmの配列を受け取ってそれを削除する方法
    
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    /// 選択しているスタイル
    @State private var selectingBackgroundStyle: BackgroundStyle = .simple
    @State private var selectedImage: UIImage?
    @State private var selectingImage: UIImage? = nil
    @StateObject var dateViewModel = DateViewModel()
    @StateObject var imageViewModel = ImageModel()
    @StateObject var eventCardViewModel: EventCardViewModel2
    
    /// シートのフラグ
    @State var showStyleAlert = false
    @State private var showDeleteAlert = false
    @State var showStyleDetailConfiguration = false
    
    @State private var opacity: Double = 0
    
    private let bgColorList: [BackgroundColor] = BackgroundColor.allCases
    private let txtColorList: [TextColor] = TextColor.allCases
    
    var body: some View {
            
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
                
                VStack(alignment: .center) {
                     HStack {
                         Spacer()
                         Spacer()
                         EventCardView2(event: event,eventVM: eventCardViewModel)
                         
                         if isCreation {
                             Spacer()
                         } else {
                             Button {
                                 self.showDeleteAlert.toggle()
                                 trashButtonSelected.toggle()
                                 FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewDeleteEvent)
                             } label: {
                                 Image(systemName: "trash.fill")
                                     .foregroundStyle(ColorUtility.highlighted2)
                             }
                             .buttonStyle(EventConfigurationButtonStyle(active: $trashButtonSelected))
                             .opacity(opacity)
                             .offset(y: opacity == 0 ? WidgetConfig.small.size.height/2 :  WidgetConfig.small.size.height/2 - 25)
                             .animation(.easeIn(duration: 0.7).delay(0.3), value: opacity)
                         }
                         Spacer()
                     }
                     .alert("このイベントを消去しますか？", isPresented: $showDeleteAlert) {
                         
                         Button("キャンセル", role: .cancel) {
                             trashButtonSelected.toggle()
                             FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapDeleteEventAlertCancel)
                         }
                         Button("消去", role: .destructive) {
                             trashButtonSelected.toggle()
                             $event.delete()
                             // 削除処理
//                                 RealmViewModel().deleteEvent(event: a)
                             
                            /// 通知の登録削除処理
                             NotificationCenter.removeNotification(id: event.id.stringValue)
                             FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapDeleteEventAlertExecution)
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
        .task {
            guard let product = try? await store.fetchProducts(ProductId.super.rawValue).first else { return }
            
            do {
                try await self.isPurchased = store.isPurchased(product)
                
                #if DEBUG
                self.isPurchased = true
                #endif
                
            } catch(let error) {
                print(error.localizedDescription)
            }
        }.onAppear{
            dateViewModel.selectedDate = event.date
            opacity = 1.0
        }
    }
    
    /// 設定選択ビュー
    private var configurationSelectionView: some View {
        HStack {
            Spacer()
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapConfigureContent)
                if !isFirstButtonSelected {
                    isFirstButtonSelected = true
                    isSecondButtonSelected = false
                    isThirdButtonSelected = false
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 23))
                    .bold(isFirstButtonSelected)
                    .scaleEffect(isFirstButtonSelected ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 5, initialVelocity: 1), value: isFirstButtonSelected)
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isFirstButtonSelected))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isFirstButtonSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
            
            Spacer()
            
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapConfigureStyle)
                if !isSecondButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = true
                    isThirdButtonSelected = false
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "wand.and.stars.inverse")
                    .font(.system(size: 23))
                    .bold(isSecondButtonSelected)
                    .scaleEffect(isSecondButtonSelected ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 5, initialVelocity: 1), value: isSecondButtonSelected)
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isSecondButtonSelected))
            
            
            Spacer()
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapConfigureBackground)
                if !isThirdButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = false
                    isThirdButtonSelected = true
                    isFourthButtonSelected = false
                }
            } label: {
                Image(systemName: "paintbrush.fill")
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .bold(isThirdButtonSelected)
                    .font(.system(size: 23))
                    .scaleEffect(isThirdButtonSelected ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 5, initialVelocity: 1), value: isThirdButtonSelected)

            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isThirdButtonSelected))

            
            Spacer()
            
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapConfigureText)
                if !isFourthButtonSelected {
                    isFirstButtonSelected = false
                    isSecondButtonSelected = false
                    isThirdButtonSelected = false
                    isFourthButtonSelected = true
                }
            } label: {
                Image(systemName: "textformat")
                    .bold(isFourthButtonSelected)
                    .font(.system(size: 23))
                    .scaleEffect(isFourthButtonSelected ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 5, initialVelocity: 1), value: isFourthButtonSelected)
            }
            .buttonStyle(EventConfigurationButtonStyle(active: $isFourthButtonSelected))
            
            Spacer()
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(ColorUtility.primary)
        .analyticsScreen(name: String(describing: Self.self),
                               class: String(describing: type(of: self)))
    }
    
    /// HeaderView
    private var headerView: some View {
        VStack(spacing: 0) {
            
            closableMark
                .padding(.top)
            
            HStack {
                Button("✗") {
                    presentationMode.wrappedValue.dismiss()
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapCloseButton)
                    
                }
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .font(.system(size: 30))
                .background(ColorUtility.secondary)
                .clipShape(Circle())
                .padding()
                
                Spacer()
                Button(isCreation ? "登録" : "更新") {
                    
                    //                if eventCardViewModel.text.isEmpty {
                    //                    ///  イベント名を入力してくださいエラーメッセージ表示
                    //                    return
                    //                }
                    let style: EventDisplayStyle = isPurchased ? eventCardViewModel.style : .standard
                    
                    let event = Event(title: eventCardViewModel.text, date: eventCardViewModel.selectedDate, textColor: eventCardViewModel.textColor, backgroundColor: eventCardViewModel.backgroundColor, displayStyle: style, fontSize: 1.0, frequentType: eventCardViewModel.frequentType, eventType: eventCardViewModel.eventType, dayOfWeek: eventCardViewModel.dayOfWeek, displayHour: eventCardViewModel.showHour, displayMinute: eventCardViewModel.showMinute, displaySecond: eventCardViewModel.showSecond, image: eventCardViewModel.image, displayLang: eventCardViewModel.displayLang)
                    HapticFeedbackManager.shared.play(.impact(.heavy))
                    switch isCreation {
                        /// 新規作成
                    case true:
                        RealmViewModel().registerEvent(event: event)
                        realmMock.cards.insert(event, at: 0)
                        /// 更新
                    case false:
                        RealmViewModel().updateEvent(event: event)
                        /// Widget側のデータ更新
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    
                    Task {
                        if eventCardViewModel.eventType == .countdown {
                            /// 許可についてまだ決めてない場合はリクエストする
                            if await NotificationCenter.checkNotificationStatus() == .notDetermined {
                                NotificationCenter.requestNotificationPermission()
                            }
                            
                            /// 許可されている場合は、通知を設定
                            if await NotificationCenter.checkNotificationStatus() == .authorized {
                                NotificationCenter.registerNotification(event: event)
                            }
                        }
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapRegisterButton)
                }
                .buttonStyle(BounceButtonStyle())
                .frame(width: 100, height: 50)
                .tint(.white)
                .fontWeight(.bold)
                .font(.system(size: 20))
                .disabled(eventCardViewModel.text.isEmpty)
                .background(RoundedRectangle(cornerRadius: 30).fill( eventCardViewModel.text.isEmpty ? ColorUtility.disable : ColorUtility.preffered))
                .padding()
                .animation(.default, value: eventCardViewModel.text.isEmpty)
            }
        }
        .frame(height: 90)
        .background(ColorUtility.primary)
    }
    @State private var showCropView = false
    /// イベントタイトル名編集もしくは日付を設定するボタンを表示するビュー
    private var eventTitleView: some View {
        VStack {
            HStack {
                ZStack(alignment: .leading) {
//
                    TextField("", text: $eventCardViewModel.text,
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
                    
                    if eventCardViewModel.text.isEmpty {
                        Text("イベント名を入力")
                            .foregroundColor(.gray)
                            .padding(.horizontal,30)
                            .allowsHitTesting(false)
                            
                    }
                }
//
                if focusField {
                    Button {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapEventNameButton)
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
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapConfigureDateButton)
            } label: {
                VStack(alignment: .leading) {
                    Text(eventCardViewModel.eventType.rawValue)
                        .foregroundColor(eventCardViewModel.eventType == .countdown ? .black : .white)
                        .frame(width: 150, height: 30)
                        .background(eventCardViewModel.eventType == .countdown ? .white : .black)
                        .cornerRadius(20)
                        .padding(.leading)
                        .padding(.bottom, 3)
                    dateView1
//
                }.sheet(isPresented: $isShowSheet) {
//                    ConfigureDateView(eventType: $eventType, frequentType: eventCardViewModel.frequentType, dateViewModel: _dateViewModel, weeklyDate: $dayOfWeek, eventViewModel: _eventCardViewModel)
                    ConfigureDateView(eventType: $eventCardViewModel.eventType, frequentType: $eventCardViewModel.frequentType, dateViewModel: _dateViewModel, weeklyDate: $eventCardViewModel.dayOfWeek, eventViewModel: _eventCardViewModel)
                }.frame(height: 120.0)
                    .frame(alignment: .leading)
                    .foregroundColor(eventCardViewModel.eventType == .countdown ? .black : .white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(eventCardViewModel.eventType == .countdown ? ColorUtility.highlighted : ColorUtility.highlighted2))

            }
                
                Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    
    @State var number = 0
    
    private var dateView1: some View {
        HStack {
//
            VStack {
                Image(systemName: eventCardViewModel.eventType == .countdown ? "calendar.badge.clock" : "clock.arrow.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 30)
                    .padding(.horizontal)
                    .foregroundStyle(eventCardViewModel.eventType == .countdown ? .white : .black)
                
                if eventCardViewModel.eventType == .countdown && eventCardViewModel.frequentType != .never {
                    Text("リピート")
                        .font(.system(size: 10))
                        .foregroundColor(eventCardViewModel.eventType == .countdown ? .white : .black)
                        .background(Color.red)
                }
            }
//
            VStack(alignment: .leading) {
                let date = dateViewModel.selectedDate
                let year = dateViewModel.getYearText(date: date)
                let month = dateViewModel.getMonthText(date: date)
                let day = dateViewModel.getDayText(date: date)
                let hour = dateViewModel.getHourText(date: date)
                let minute = dateViewModel.getMinuteText(date: date)
                
                HStack {
                    switch eventCardViewModel.eventType {
                    case .countup:
                        Text(year + "/" + month + "/" + day)
                    case .countdown:
                        switch eventCardViewModel.frequentType {
                        case .never:
                            Text(year + "/" + month + "/" + day)
                        case .annual:
                            Text("毎年：")
                            Text(month + "月" + day + "日")
                        case .monthly:
                            Text("毎月：")
                            Text(day + "日")
                        case .weekly:
                            Text("毎週：")
                            Text(eventCardViewModel.dayOfWeek.stringValue)
                        }
                    }
                    
                }
                /// TODO:- hh:mm表記
                Text(hour + ":" + minute)
                
            }
            .foregroundColor(eventCardViewModel.eventType == .countdown ? .white : .black)
            Spacer()
        }
    }
    
    /// イベントの表示スタイルを編集するビュー
    ///他のところで使われていないので、ファンクションに切り出す方が良いかも
    private var styleView: some View {
        VStack {
            TabView(selection: $selectedStyleIndex) {
                ZStack {
                    VStack {
                        ZStack {
                            Text("👍スタンダード")
                                .foregroundStyle(.white)
                                .font(.system(size: 40, weight: .bold))
                        }
                        Divider()
                        Spacer()
                    }
                    
                    VStack {
                        EventCardView2(event: event, eventVM: eventCardViewModel)
                        
                        Button {
                            showStyleDetailConfiguration.toggle()
                        } label: {
                            Text("詳細設定")
                                .font(.system(size: 15))
                            
                        }
                        .buttonStyle(BounceButtonStyle())
                        .padding(8)
                        .background(.white).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                    }
                }
                .tag(0)
                ZStack {
                    
                    VStack {
                        Text("🍩リング")
                            .foregroundStyle(.white)
                            .font(.system(size: 40, weight: .bold))
                        Spacer()
                    }
                    
                    VStack {
                        Text(eventCardViewModel.eventType.rawValue)
                            .foregroundColor(ColorUtility.highlightedText)
                        EventCardView2(eventVM: eventCardViewModel, displayStyle: .circle)
                        
                        switch eventCardViewModel.eventType {
                        case .countdown:
                            switch eventCardViewModel.frequentType {
                            case .never:
                                Text("イベント作成日からゴールまでを１周")
                                    .foregroundColor(ColorUtility.highlightedText)
                            case .annual:
                                Text("１年で１周")
                                    .foregroundColor(ColorUtility.highlightedText)
                            case .monthly:
                                Text("１ヶ月で１周")
                                    .foregroundColor(ColorUtility.highlightedText)
                            case .weekly:
                                Text("１週間で１周")
                                    .foregroundColor(ColorUtility.highlightedText)
                            }
                            
                        case .countup:
                            Text("１００日で１周")
                                .foregroundColor(ColorUtility.highlightedText)
                        }
                        
                    }
                    if !isPurchased {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Button {
                                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapUpgradeFromCircleViewStyle)
                                showStyleAlert.toggle()
                            } label: {
                                Color.clear
                                    .frame(width: 200, height: 200)
                            }
                            .frame(width: 200, height: 200)
                            .background(.black)
                            .opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            Text("このスタイルはロックされています")
                                .foregroundColor(.white)
                        }
                    }
                }.tag(1)
                
                ZStack {
                    
                    VStack {
                        Text("📅カレンダー")
                            .foregroundStyle(.white)
                            .font(.system(size: 40, weight: .bold))
                        Spacer()
                    }
                    
                    VStack {
                        
                        
                        EventCardView2(eventVM: eventCardViewModel, displayStyle: .calendar)
                        
                    }
                    if !isPurchased {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Button {
                                FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewTapUpgradeFromCalendarViewStyle)
                                showStyleAlert.toggle()
                            } label: {
                                Color.clear
                                    .frame(width: 200, height: 200)
                            }
                            .frame(width: 200, height: 200)
                            .background(.black)
                            .opacity(0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            Text("このスタイルはロックされています")
                                .foregroundColor(.white)
                        }
                    }
                }.tag(2)
                
            }
            .onChange(of: selectedStyleIndex, perform: { newValue in
//                eventCardViewModel.style = EventDisplayStyle(rawValue: selectedStyleIndex)!
                eventCardViewModel.style = isPurchased ? EventDisplayStyle(rawValue: selectedStyleIndex)! : .standard
            })
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .sheet(isPresented: $showStyleDetailConfiguration) {
                
                EventDetailConfigurationView(showHour: $eventCardViewModel.showHour, showMinute: $eventCardViewModel.showMinute, displayLang: $eventCardViewModel.displayLang, showSecond: $eventCardViewModel.showSecond)
                    .presentationDetents([.medium])
                    
            }
            .alert("このスタイルを利用するにはアップグレードが必要です", isPresented: $showStyleAlert) {
                Button("OK") {
                    isShowUpgradeView.toggle()
                }
            }.sheet(isPresented: $isShowUpgradeView) {
                UpgradeView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    enum BackgroundStyle: String, CaseIterable {
        
        case simple = "シンプル"
        case image = "画像"
    }
    @State private var photosItem: PhotosPickerItem? = nil
    /// MARK: - 背景色を編集するビュー
    private var backgroundColorView: some View {
        VStack {
            
            Picker("背景スタイル", selection: $selectedBackgroundStyle) {
                ForEach(BackgroundStyle.allCases, id: \.self) { id in
                    Text(id.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedBackgroundStyle {
            case .simple:
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(bgColorList, id: \.self) { item in
                            if let color = item.color {
                                RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [color, color], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(item == eventCardViewModel.backgroundColor ? .red : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture(perform: {
                                        eventCardViewModel.backgroundColor = item
                                        selectingBackgroundStyle = .simple
                                        print(color)
                                    })
                                    .padding()
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .image:
                ScrollView(showsIndicators: false) {
                    ZStack {
                        if let image = selectedImage {
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .frame(width: 150, height: 150)
                                    .overlay(content: {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(lineWidth: 5)
                                            .fill(eventCardViewModel.backgroundColor == .none ? .red : .clear)
                                    })
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        showCropView.toggle()
                                    }
                                    .photosPicker(isPresented: $show, selection: $photosItem)
                                    .onChange(of: photosItem) { newValue in
                                        
                                            Task {
                                                if let imageData = try? await newValue?.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                                                    await MainActor.run(body: {
                                                        selectingImage = image
                                                        showCropView.toggle()
                                                    })
                                                }
                                            }
                                        
                                    }
                                
                                Button {
                                    show.toggle()
                                } label: {
                                    Text("画像を変更")
                                        .fontWeight(.bold)
                                        .frame(width: 130, height: 60)
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                }
                                .padding()
                            }
                           
                            }  else {
                                Rectangle()
                                    .cornerRadius(20)
                                    .foregroundColor(.gray)
                                    .frame(width: 150, height: 150)
                                    .overlay(alignment: .center) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .resizable()
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "plus.circle.fill")
                                            .offset(x: 25, y: 25)
                                            .symbolRenderingMode(.multicolor)
                                            .font(.system(size: 30))
                                            .foregroundColor(.blue)
                                            
                                    }
                                    .onTapGesture {
                                        show.toggle()
                                    }
                                    .photosPicker(isPresented: $show, selection: $photosItem)
                                    .onChange(of: photosItem) { newValue in
                                        if let newValue {
                                            Task {
                                                if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                                                    await MainActor.run(body: {
                                                        selectingImage = image
                                                        showCropView.toggle()
                                                    })
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                }
                .alert("画像設定にはアップグレードが必要です", isPresented: $isShowUpgradeAlert) {
                    Button("OK") {
                        isShowUpgradeView.toggle()
                    }
                }
                .sheet(isPresented: $isShowUpgradeView) {
                    UpgradeView()
                }
                .sheet(isPresented: $showCropView) { [ selectingImage] in
                    CropView(image: selectingImage) { croppedImage, status in
                        if let croppedImage {
                            self.selectedImage = croppedImage
                            self.eventCardViewModel.image = croppedImage
                            self.eventCardViewModel.backgroundColor = .none
                            FirebaseAnalyticsManager.recordEvent(analyticsKey: .ConfigureViewSelectBacgkroundImage)
                        } else {
                            /// 画像編集エラー
                        }
                    }
                }
            }
            
        }
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
    }
    @State private var isShowUpgradeView = false
    @State private var isShowUpgradeAlert = false
    @State private var show = false
    /// テキストの色を編集するビュー
    private var textColorView: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(txtColorList, id: \.self) { item in
                        
                        Text("Aa")
                            .foregroundColor(item.color)
                            .font(.system(size: 50))
                            .frame(width: 80, height: 80)
                            .border(item == eventCardViewModel.textColor ?  .red : .clear)
                            .onTapGesture(perform: {
                                eventCardViewModel.textColor = item
                                print(item.color)
                            })
                    }
                }
            }
            .padding()
            
            VStack {
                Spacer()
                Button {
                    withAnimation {
                        eventCardViewModel.displayLang = eventCardViewModel.displayLang.rawValue == 0 ? .en : .jp
                    }
                    
                } label: {
                    let text = eventCardViewModel.displayLang == .jp ? "日" : "Day"
                    Text(text)
                        .foregroundColor(.black)
                    
                }
                .frame(width: 50, height: 50)
                .background(.white)
                .clipShape(Circle())
                .buttonStyle(BounceButtonStyle())
                .padding()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(ColorUtility.backgroundary)
        
    }
}
    

/// Appleのコードを参考に作ったPhoto picker用のコード。使ってない
struct BackgroundImage: View {
    let imageState: ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image.resizable()
        case .loading:
            ProgressView()
        case .empty:
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(.white)
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

struct EditBackgroundImage: View {
    let imageState: ImageState
    let imageViewModel: ImageModel
    
    var body: some View {
        BackgroundImage(imageState: imageState)
            .scaledToFill()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 150, height: 150)
            .background {
                RoundedRectangle(cornerRadius: 20).fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
            }
            .border(imageViewModel.imageSelection != nil ? .red : .clear)
            .cornerRadius(20)
            
        
    }
}



struct ConfigureEventView_Previews: PreviewProvider {
    @State static var event = EventCardViewModel.defaultStatus
    @State static var eventViewModel = EventCardViewModel2(event: event)
    @State static var eventTitle = ""
    @State static var events = try! Realm().objects(Event.self)
    @State static var date = EventCardViewModel.defaultStatus.date
    @StateObject static var store = Store()
    static var previews: some View {
        ConfigureEventView(realmMock: RealmMockStore(), event: $event, isCreation: false, eventCardViewModel: eventViewModel).environmentObject(store)
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
