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

struct MainView: View {
    @StateObject var store: Store = Store()
    @State private var isShow = false
    @State private var isShowConfigured = false
    @State private var isShowUpgradeAlert = false
    @State private var isShowUpgradeView = false
    @State private var isSettingButton = false
    @State private var product: Product?
    @State private var isPurchased = false
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
//                                Image(uiImage: UIImage(data: card.imageData! as Data)!)
                                
//                                print("IMAGE")
//                                print(image)
                                EventCardView(title: card.title, date: card.date, style: card.displayStyle, backgroundColor: card.backgroundColor, image: image, textColor: card.textColor, frequentType: card.frequentType)
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
                                    
                            }
                            
                        }
                    }.sheet(isPresented: $isShowConfigured) {
                        
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: false)
                    }.sheet(isPresented: $isShow) {
                        ConfigureEventView(realmMock: realmMock, event: $selectedEvent, isCreation: true)
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
    
    private var headerView: some View {
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
        .background(ColorUtility.primary)
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
