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
//    @StateObject var mock = MockStore()
    @StateObject var realmMock = RealmMockStore()
//    @StateObject var defaultEvent = EventCardViewModel.defaultStatus
    @EnvironmentObject var viewModel: RealmViewModel
    @State private var scale = false
    let dateViewModel = DateViewModel()
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
    ]
    let itemPerRow: CGFloat = 5
    let horizontalSpacing: CGFloat = 15
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
        VStack {
            headerView
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    
                    ForEach(0 ..< realmCards.count + 1, id: \.self) { i in
                        VStack {
                            if i >= 1 {
                                let card = realmCards[i - 1]
                                
                                let image = createImage(cardImage: card)
                                EventCardView(title: card.title, date: card.date, style: card.displayStyle, backgroundColor: card.backgroundColor, image: image, textColor: card.textColor, frequentType: card.frequentType)
                                    .onTapGesture {
                                        
                                        selectedEvent = realmCards[i - 1]
                                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewUpdateEvent)
                                        isShowConfigured.toggle()
                                        self.selectedIndex = i
                                        let _ = print(i)
                                        let _ = print(selectedEvent.title)
                                    }
                                    .contextMenu {
                                        let cardView = EventCardView(title: card.title, date: card.date, style: card.displayStyle, backgroundColor: card.backgroundColor, image: image, textColor: card.textColor, frequentType: card.frequentType)
                                        let render = ImageRenderer(content: cardView)
                                        if let imageSnap = render.uiImage {
                                            ShareLink(item: Image(uiImage: imageSnap),
                                                      preview: SharePreview("CountDays", image: Image(systemName: "square.and.arrow.up")),
                                                      label: {
                                                HStack {
                                                    Image(systemName: "square.and.arrow.up")
                                                    Text("MyShareLabel")
                                                }
                                            })
                                        }

                                    }
                                    

                            } else if i == 0 {
                                AddEventView()
                                    .padding()
                                    .scaleEffect(scale ? 1.1: 1.0)
                                    .simultaneousGesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { _ in
                                                    withAnimation {
                                                        scale = true
                                                    }
                                                    
                                                }
                                                
                                                .onEnded { _ in
                                                    HapticFeedbackManager.shared.play(.impact(.medium))
                                                    withAnimation {
                                                        scale = false
                                                    }
                                                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .MainViewAddEvent)
                                                    /// 課金ユーザーかどうかを判定し、課金してたら２個以上OK。無課金は１個まで
                                                    
                                                    #if DEBUG
                                                    isShow.toggle()
                                                    selectedEvent = EventCardViewModel.defaultStatus
                                                    #else
                                                    if self.isPurchased {
                                                        /// 課金ユーザー
                                                        isShow.toggle()
                                                        selectedEvent = EventCardViewModel.defaultStatus
                                                    } else {
                                                        
                                                        ///　無課金
                                                        isShowUpgradeAlert.toggle()
                                                    }
                                                    #endif
                                                }
                                        )
                                    .contextMenu {
                                        ShareLink(item: "Hello",
                                                  preview: SharePreview("CountDays", image: Image(systemName: "square.and.arrow.up")),
                                                  label: {
                                            HStack {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("MyShareLabel")
                                            }
                                        })
                                    }
                            }
                            
                        }
                    }.sheet(isPresented: $isShowConfigured) {[selectedEvent] in
                        
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: false, eventCardViewModel: EventCardViewModel2(event: selectedEvent))
                            .environmentObject(store)
                        
                    }.sheet(isPresented: $isShow) {
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: true, eventCardViewModel: EventCardViewModel2(event: EventCardViewModel.defaultStatus))
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
                            try await self.isPurchased = store.isPurchased(product)
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
            .background(ColorUtility.backgroundary)
            
            Spacer()
            
            #if DEBUG
            Text("Launch Time:\(counter)")
            Button {
                
                print("notification request")
                NotificationCenter.sendNotificationRequest()
                
            } label: {
                Text("Notification")
            }
            #endif
            let _ = print("selc: \(self)")
        }
        .background(ColorUtility.backgroundary)
        .analyticsScreen(name: String(describing: Self.self),
                               class: String(describing: type(of: self)))
    }
    
    private var headerView: some View {
        HStack {
            Text(greetingString())
                .font(.system(size: 35,weight: .bold))
                .padding()
            Spacer()
            
            Button {
                isSettingButton.toggle()
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
    
    private func greetingString() -> String {
        if counter == 1 {
            return "はじめまして"
        }
        
        let greetingList = ["ようこそ", "こんにちは", "調子どう？", "Thanks", "🫶"]
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
        MainView()
    }
}
