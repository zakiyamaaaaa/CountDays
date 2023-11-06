//
//  UpgradeView.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/08/31.
//

import SwiftUI
import StoreKit

struct UpgradeView: View {
    @EnvironmentObject var store: Store
    @State var isPurchased = false
    @State var product: Product?
//    private let productID = "com.temporary.id"
    @StateObject var viewModel = ProductViewModel()
    @State private var errorTitle = ""
    @State private var isShowingError = false
    @State private var isShowRestoreAlert = false
    @State private var shadowRadius: CGFloat = 5
    
    private var decorateText: some View {
        /// :- FIXME
        let str = "アップグレードをすると次の機能が使えるようになります"
        let strl = LocalizedStringResource(stringLiteral: str)
        var attributedString = AttributedString(localized: strl)
        
        attributedString.font = .system(size: 30, weight: .bold)
        attributedString.foregroundColor = .white
        
        let upgradeText: [(word: String, locale: String)] = [
            (word: "Upgrading", locale:"en"),
            (word: "アップグレード", locale:"ja"),
            (word: "La actualización", locale:"es"),
            (word: "升级后", locale:"zh"),
        ]
        
        upgradeText.forEach { w,l in
            if let range = attributedString.range(of: w, locale: Locale(identifier: l)) {
                attributedString[range].foregroundColor = .yellow
                attributedString[range].font = .system(size: 30, weight: .bold)
            }
        }
        
       return Text(attributedString)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "アップグレード")
            
            
            
            ScrollView {
                VStack(alignment: .leading) {
                    //#if DEBUG
                    //                    Text("アップグレード")
                    //
                    //                    let price = product?.price ?? 0
                    //                    let displayPrice = product?.displayPrice ?? ""
                    //                    let priceFormatStyle = product?.priceFormatStyle ?? Decimal.FormatStyle.Currency(code: "JPY")
                    //                    Text(price, format: priceFormatStyle)
                    //                    Text(displayPrice)
                    //#endif
                    
                    decorateText
                        .padding(.bottom, 40)
                        .padding(.top, 20)
                    Group {
                        Text("好きなだけイベントを作成可能に！")
                            .foregroundColor(.pink)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("作成できるイベント数の上限が１個から無制限になります")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Image("upgrade1")
                            .padding(.vertical, 30)
                    }
                    .padding(.bottom, 10)
                    
                    Group {
                        Text("背景に画像を設定可能に！")
                            .foregroundColor(.pink)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("あなただけのオリジナル背景を設定できます")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            
                        
                        Image("upgrade2")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 30)
                    }
                    .padding(.bottom, 10)
                    
                    Group {
                        Text("様々な表示スタイルが選択可能に！")
                            .foregroundColor(.pink)
                            .font(.title)
                            .fontWeight(.bold)
                            
                        
                        Text("あなたの好きなデザインを選ぶことができます")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Image("upgrade3")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 30)
                    }
                    .padding(.bottom, 10)
                    
                    
                    Group {
                        Text("追加機能を先行招待！")
                            .foregroundColor(.pink)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom,3)
                        
                        Text("アップデートによる追加機能を先行して利用することができます")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        VStack(alignment: .center) {
                            Image("upgrade4")
                                .resizable()
                                .scaledToFit()
                                
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
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
            .frame(maxWidth: .infinity)
            .background(Color.black.gradient)
            
            VStack {
                Button {
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .UpgradeViewTapRestoreButton)
                    if isPurchased {
                        /// 購入復元処理
                        Task {
                            try? await AppStore.sync()
                        }
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .UpgradeViewRestore)
                    } else {
                        isShowRestoreAlert.toggle()
                    }
                } label: {
                    Text("購入を復元")
                        .foregroundStyle(.blue)
                }
                .padding()
                
                Button {
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .UpgradeViewTapPurchaseButton)
                    Task {
                        
                        /// 購入処理
                        await buy()
                    }
                } label: {
                    let displayPrice = product?.displayPrice ?? ""
                    VStack {
                        Text("購入")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("（" + displayPrice + "/月）")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            
                    }
                    .frame(width: 200, height: 60)
                    
                }
                .disabled(isPurchased)
                .foregroundStyle(.black)
                .background(isPurchased ? .gray : Color.accentColor)
                .cornerRadius(30)
                .shadow(color: isPurchased ? .gray : .accentColor, radius: shadowRadius, x: 0.0, y: 0.0)
                .animation(.easeIn(duration: 1.5).repeatForever(autoreverses: true), value: shadowRadius)
                .onAppear {
                    shadowRadius = 10
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(ColorUtility.secondary)
            .alert("購入記録がありません", isPresented: $isShowRestoreAlert) {
                Button("OK") {
                    
                }
            }
            .analyticsScreen(name: String(describing: Self.self),
                             class: String(describing: type(of: self)))
        }
    }
        
    
    func buy() async {
        do {
            if let product = product, try await self.store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
                FirebaseAnalyticsManager.recordEvent(analyticsKey: .UpgradeViewPurchase)
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store"
            isShowingError = true
        } catch {
            print("Failed purchase")
        }
    }
}

struct UpgradeView_Previews: PreviewProvider {
    @StateObject static var store = Store()
    static var previews: some View {
        ForEach(Global.localizationIds, id: \.self) { id in
            UpgradeView()
                .environmentObject(store)
                .previewDisplayName("Locale- \(id)")
                .environment(\.locale, .init(identifier: id))
        }
    }
}

enum ProductId: String {
    case `super` = "zakiyamaaaaa.CountDays.subscription.super"
    case premium = "premium"
}
