//
//  MainView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI
import Algorithms
import RealmSwift
import StoreKit
import FirebaseAnalyticsSwift
import FirebaseAnalytics

struct MainView: View {
    @AppStorage(AppStorageKey.launchTimes.rawValue) var counter = 0
    @StateObject var store: Store = Store()
    @State private var isShow = false
    @State private var isShowConfigured = false
    @State private var isShowUpgradeAlert = false
    @State private var isShowUpgradeView = false
    @State private var isSettingButton = false
    @State private var isShowWelcomeView = false
    @State private var product: Product?
    @State private var isPurchased = false
//    @State private var isPurchased2 = false
//    @StateObject var realmMock = MockStore()
    @StateObject var realmMock = RealmMockStore()
//    @StateObject var defaultEvent = EventCardViewModel.defaultStatus
    @EnvironmentObject var viewModel: RealmViewModel
    @State private var scale = false
    let dateViewModel = DateViewModel()
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @ObservedResults(Event.self, configuration: RealmModel.config) var realmCards
    @State var selectedEvent = Event()
    @State var selectedIndex = 0
    var selectedEventStyle: EventDisplayStyle = .standard
    
    func createImage(cardImage: Event ) -> UIImage? {
        var image: UIImage? = nil
        if let data = cardImage.imageData, let uiImage = UIImage(data: data as Data) {
            image = uiImage
        }
        
        return image
    }
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    
                    ForEach(0 ..< realmCards.count + 1, id: \.self) { i in
                        VStack {
                            if i >= 1 {
                                let card = realmCards[i - 1]
                                EventCardView2(event: card, eventVM: EventCardViewModel2(event: card))
                                    .padding(.top)
                                    .onTapGesture {
                                        HapticFeedbackManager.play(.impact(.medium))
                                        selectedEvent = realmCards[i - 1]
                                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewUpdateEvent)
                                        isShowConfigured.toggle()
                                        self.selectedIndex = i
                                        let _ = print(i)
                                        let _ = print(selectedEvent.title)
                                    }
                                    .contextMenu {
                                        let cardView = EventCardView2(event: card, eventVM: EventCardViewModel2(event: card))
                                        let render = ImageRenderer(content: cardView)
                                        if let imageSnap = render.uiImage {
                                            ShareLink(item: Image(uiImage: imageSnap),
                                                      preview: SharePreview("CountDays", image: Image(systemName: "square.and.arrow.up")),
                                                      label: {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.up")
                                                    Text("イベントを共有")
                                                }
                                            })
                                            Button {
                                                selectedEvent = card
                                                FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewUpdateEvent)
                                                isShowConfigured.toggle()
                                                self.selectedIndex = i
                                                let _ = print(i)
                                                let _ = print(selectedEvent.title)
                                            } label: {
                                                HStack {
                                                    Image(systemName: "square.and.pencil")
                                                    Text("編集")
                                                }
                                                
                                            }
                                            
                                            Menu {
                                                Button {
                                                    RealmViewModel().deleteEvent(event: card)
                                                } label: {
                                                    
                                                    Text("削除を確定")
                                                    
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "trash")
                                                    Text("削除")
                                                }
                                            }

                                        }

                                    }
                                    
                            } else if i == 0 {
                                AddEventView()
                                    .padding(.top)
                                    .scaleEffect(scale ? 1.1: 1.0)
                                    .simultaneousGesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { _ in
                                                    withAnimation {
                                                        scale = true
                                                    }
                                                    
                                                }
                                                
                                                .onEnded { _ in
                                                    
                                                    withAnimation {
                                                        scale = false
                                                    }
                                                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewAddEvent)
                                                    /// 課金ユーザーかどうかを判定し、課金してたら２個以上OK。無課金は１個まで
                                                    
//                                                    #if DEBUG
//                                                    isShow.toggle()
//                                                    selectedEvent = EventCardViewModel.defaultStatus
//                                                    #else
                                                    
                                                    #if DEBUG
                                                    self.isPurchased = true
                                                    #endif
                                                    
                                                    if self.isPurchased || RealmViewModel().events.count == 0 {
                                                        HapticFeedbackManager.play(.impact(.medium))
                                                        /// 課金ユーザー
                                                        isShow.toggle()
                                                        selectedEvent = EventCardViewModel.defaultStatus
                                                    } else {
                                                        HapticFeedbackManager.play(.notification(.error))
                                                        ///　無課金
                                                        isShowUpgradeAlert.toggle()
                                                    }
//                                                    #endif
                                                }
                                        )
                                    
                            }
                            
                        }
                    }.sheet(isPresented: $isShowConfigured) {[selectedEvent] in
                        
                        ConfigureEventView(realmMock: realmMock, event: selectedEvent, isCreation: false, eventCardViewModel: EventCardViewModel2(event: selectedEvent))
                            .environmentObject(store)
                        
                    }.sheet(isPresented: $isShow) {
                        ConfigureEventView(realmMock: realmMock, event: selectedEvent, isCreation: true, eventCardViewModel: EventCardViewModel2(event: EventCardViewModel.defaultStatus))
                            .environmentObject(store)
                    }.sheet(isPresented: $isSettingButton) {
                        SettingView()
                    }.sheet(isPresented: $isShowUpgradeView) {
                        UpgradeView()
                    }
                    .alert("２個以上のイベントを作成するにはアップグレードが必要です", isPresented: $isShowUpgradeAlert) {
                        Button("OK") {
                            isShowUpgradeView.toggle()
                        }
                    }
                    .task {
                        guard let product = try? await store.fetchProducts(ProductId.super.rawValue).first else { return }
                        self.product = product
                        do {
                            try await self.isPurchased = store.isPurchased(ProductId.super.rawValue)
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            .onAppear {
                if counter == 0 {
                    isShowWelcomeView.toggle()
                }
                counter += 1
            }
            .sheet(isPresented: $isShowWelcomeView, content: {
                WelcomeView()
            })
            
            
            Spacer()
            
            #if DEBUG
//            VStack {
//                Text("デバッグモード")
//                Text("課金状態：" + isPurchased.description)
//            }
//            .background(ColorUtility.backgroundary)
//            Text("Launch Time:\(counter)")
//            Button {
//                
//                print("notification request")
//                NotificationCenter.sendNotificationRequest()
//                
//            } label: {
//                Text("Notification")
//            }
            #endif
            let _ = print("self: \(self)")
        }
        .background(ColorUtility.primary.gradient)
        .analyticsScreen(name: String(describing: Self.self),
                               class: String(describing: type(of: self)))
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .listRowSeparatorLeading) {
                Text(greetingText)
                    .font(.system(size: 35,weight: .bold))
                    
                Spacer()
                HStack {
                    /// FIXME
                    let grade: LocalizedStringKey = isPurchased ? "Super" : "ノーマル"
                    Text("Status:")
                        .foregroundStyle(isPurchased ? .yellow : .white)
                    Text(grade)
                        .foregroundStyle(isPurchased ? .yellow : .gray)
                        
                }
                .font(.system(size: 12, weight: .bold))
            }
            .padding()
            
            Spacer()
            
            Button {
                isSettingButton.toggle()
                HapticFeedbackManager.play(.notification(.success))
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewTapSettingButton)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 30,height: 30)
            }
            .padding()
        }
        .foregroundColor(.white)
        .frame(height: 80)
        .background(ColorUtility.primary)
    }
    
    private var greetingText: LocalizedStringKey {
        if counter == 1 {
            return "はじめまして"
        }
        
        let greetingList: [LocalizedStringKey] = ["ようこそ", "こんにちは", "調子どう？", "Thanks", "🫶"]
        return greetingList.shuffled().first!
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
        
        ForEach(Global.localizationIds, id: \.self) { id in
            MainView()
                .previewDisplayName("Locale- \(id)")
                .environment(\.locale, .init(identifier: id))
        }
        
    }
}
