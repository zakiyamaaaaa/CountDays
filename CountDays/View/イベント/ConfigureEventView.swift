
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

struct ConfigureEventView: View {
    
    /// 毎年のイベントの場合、どのようにDateを処理すればいいか
    /// FrequentTypeによって日にちのカウント方法を変更する
    /// .annualの場合、365のあまり、もしくは
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: Store
    @State var isPurchased = false
    @State private var eventName = ""
    @State private var isShowSheet = false
    @State private var isFirstButtonSelected = true
    @State private var isSecondButtonSelected = false
    @State private var isThirdButtonSelected = false
    @State private var isFourthButtonSelected = false
    @State private var focusButton = false
    @State var selectedStyleIndex = 0
    @State var selectingStyleIndex = 0
    @State private var selectedBackgroundStyle: BackgroundStyle = .simple
//    @State private var selectedBackgroundImage: Image
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
    @State var displayLang: DisplayLang = .jp
    @State var showStyleAlert = false
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    /// 選択しているスタイル
    @State private var selectingBackgroundStyle: BackgroundStyle = .simple
    @State private var selectedImage: UIImage?
    @State private var selectingImage: UIImage?
    @State var selectedBackgroundColor: BackgroundColor = .primary {
        didSet {
            HapticFeedbackManager.shared.play(.impact(.light))
        }
    }
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @StateObject var dateViewModel = DateViewModel()
    @StateObject var imageViewModel = ImageModel()
    @State var frequentType: FrequentType = .never
    @State var eventType: EventType = .countup
    @State var dayOfWeek: DayOfWeek = .sunday
//    var selectedStyle: EventDisplayStyle = .standard
    private let bgColorList: [BackgroundColor] = BackgroundColor.allCases
    private let txtColorList: [TextColor] = TextColor.allCases
    
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
                    let style: EventDisplayStyle = isPurchased ? EventDisplayStyle(rawValue: selectedStyleIndex)! : .standard
                     ZStack {
                         EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: style, backgroundColor: selectedBackgroundColor, image: selectedImage, textColor: selectedTextColor, showHour: showHour, showMinute: showMinute, showSecond: showSecond, displayLang: displayLang, frequentType: frequentType, eventType: eventType)
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
        .task {
            guard let product = try? await store.fetchProducts(ProductId.super.rawValue).first else { return }
            
            do {
                try await self.isPurchased = store.isPurchased(product)
                
                #if DEBUG
                self.isPurchased = false
                #endif
                
            } catch(let error) {
                print(error.localizedDescription)
            }
        }
        .onAppear{
        
            print(event.date)
            eventTitle = event.title
            eventDate = event.date
            dateViewModel.selectedDate = event.date
            showHour = event.displayHour
            showMinute = event.displayMinute
            showSecond = event.displaySecond
            selectedBackgroundColor = event.backgroundColor
            selectedTextColor = event.textColor
            displayLang = event.displayLang
        }
    }
    @State private var bounce = false
    /// 設定選択ビュー
    private var configurationSelectionView: some View {
        HStack {
            Spacer()
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
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
                    .stroke(isFirstButtonSelected ? Color.red : .clear, lineWidth: 2)
            )
            
            Spacer()
            
            Button {
                HapticFeedbackManager.shared.play(.impact(.medium))
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
            Button(isCreation ? "登録" : "更新") {
                
                if eventTitle.isEmpty {
                    /// TODO: イベント名を入力してくださいエラーメッセージ表示
                    return
                }
                let style: EventDisplayStyle = isPurchased ? EventDisplayStyle(rawValue: selectedStyleIndex)! : .standard
                let event = Event(title: eventTitle, date: dateViewModel.selectedDate, textColor: selectedTextColor, backgroundColor: selectedBackgroundColor, displayStyle: style, fontSize: 1.0, dayOfWeek: dayOfWeek, displayHour: showHour, displayMinute: showMinute, displaySecond: showSecond, image: selectedImage)
                HapticFeedbackManager.shared.play(.impact(.heavy))
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
            .buttonStyle(BounceButtonStyle())
            .frame(width: 100, height: 50)
            .tint(.white)
            .fontWeight(.bold)
            .font(.system(size: 20))
            .disabled(eventTitle.isEmpty)
            .background(RoundedRectangle(cornerRadius: 30).fill( eventTitle.isEmpty ? ColorUtility.disable : ColorUtility.preffered))
            .padding()
            .animation(.default, value: eventTitle.isEmpty)
        }
        .frame(height: 80)
        .background(ColorUtility.primary)
    }
    @State private var showCropView = false
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
                VStack(alignment: .leading) {
                    Text(eventType.rawValue)
                        .foregroundColor(.black)
                        .frame(width: 150, height: 30)
                        .background(.white)
                        .cornerRadius(20)
                        .padding(.leading)
                        .padding(.bottom, 3)
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
                    
                }.sheet(isPresented: $isShowSheet) {
                    ConfigureDateView(eventType: $eventType, frequentType: $frequentType, dateViewModel: _dateViewModel, weeklyDate: $dayOfWeek)
                    
                }.frame(height: 120.0)
                    .frame(alignment: .leading)
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.highlighted))
                
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
                    EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: .standard, backgroundColor: selectedBackgroundColor, image: selectedImage, textColor: selectedTextColor, showHour: showHour, showMinute: showMinute, showSecond: showSecond, displayLang: displayLang, frequentType: frequentType, eventType: eventType)
                        
                        
                    Button {
                        showStyleDetailConfiguration.toggle()
                    } label: {
                        Text("詳細設定")
                    }
                }
                .tag(0)
                ZStack {
                    
                    EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: .circle, backgroundColor: selectedBackgroundColor, image: selectedImage, textColor: selectedTextColor, showSecond: showSecond, displayLang: displayLang, frequentType: frequentType)
                        
                    if !isPurchased {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Button {
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
                    
                    EventCardView(title: eventTitle.isEmpty ? initialEventName : eventTitle, date: date, style: .calendar, backgroundColor: selectedBackgroundColor, image: selectedImage, textColor: selectedTextColor, showSecond: showSecond, displayLang: displayLang, frequentType: frequentType)
                        
                    if !isPurchased {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Button {
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
                print(newValue)
            })
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .sheet(isPresented: $showStyleDetailConfiguration) {
                
                EventDetailConfigurationView(showHour: $showHour, showMinute: $showMinute, displayLang: $displayLang, showSecond: $showSecond)
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
    @State private var photosItem: PhotosPickerItem?
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
                                            .stroke(item == selectedBackgroundColor ? .red : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture(perform: {
                                        selectedBackgroundColor = item
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
                                            .fill(selectedBackgroundColor == .none ? .red : .clear)
                                    })
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        showCropView.toggle()
//                                        if selectedBackgroundColor != .none {
//                                            selectedBackgroundColor = .none
//                                            selectingImage = selectedImage
//                                            showCropView.toggle()
//                                        } else {
//                                            showCropView.toggle()
//                                        }
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

//                                .photosPicker(isPresented: $show, selection: $photosItem)
//                                .onChange(of: photosItem) { newValue in
//                                    if let newValue {
//                                        Task {
//                                            if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
//                                                await MainActor.run(body: {
//                                                    selectingImage = image
//                                                    showCropView.toggle()
//                                                })
//                                            }
//                                        }
//                                    }
//                                }
//                                .overlay(alignment: .center) {
//                                    PhotosPicker(selection: $selectedPhoto, label: {
//                                        Rectangle()
//                                            .frame(width: 150, height: 150)
//                                        .foregroundColor(.clear)
////                                        Button {
////
////                                        } label: {
////                                            Text("BUTTON")
////                                        }
////                                        .frame(width: 150, height: 150)
////                                        .background(.orange)
////                                        .foregroundColor(.orange)
//
//                                    })
//                                    .onChange(of: selectedPhoto) { pickedItem in
//                                        Task {
//                                            if let data = try? await pickedItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
//                                                selectedImage = uiImage
//                                            }
//                                        }
//                                    }
//                                }
                           
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
                                    
//                                    .cropImagePicker(show: $show, croppedImage: $selectedImage  )
                                    
                                if isPurchased {
                                    
//                                    PhotosPicker(selection: $selectedPhoto, label: {
//                                        Rectangle()
//                                            .frame(width: 150, height: 150)
//                                            .foregroundColor(.clear)
//
//                                    })
                                } else {
                                    
                                    Button {
                                        isShowUpgradeAlert.toggle()
                                    } label: {
                                        Text("")
                                            .frame(width: 150, height: 150)
                                    }
                                    .background(.clear)
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
                .sheet(isPresented: $showCropView, content: {
                    CropView(image: selectingImage) { croppedImage, status in
                        if let croppedImage {
                            self.selectedImage = croppedImage
                            selectedBackgroundColor = .none
                        } else {
                            /// 画像編集エラー
                        }
                    }
                })
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
                            .border(item == selectedTextColor ?  .red : .clear)
                            .onTapGesture(perform: {
                                selectedTextColor = item
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
                        displayLang = displayLang.rawValue == 0 ? .en : .jp
                    }
                    
                } label: {
                    let text = displayLang == .jp ? "日" : "Day"
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
    @State static var eventTitle = ""
    @State static var events = try! Realm().objects(Event.self)
    @State static var date = EventCardViewModel.defaultStatus.date
    @StateObject static var store = Store()
    static var previews: some View {
        ConfigureEventView(realmMock: RealmMockStore(), event: $event, isCreation: true, eventTitle: eventTitle).environmentObject(store)
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
