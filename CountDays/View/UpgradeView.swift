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
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "アップグレード")
            ScrollView {
                VStack(alignment: .leading) {
#if DEBUG
                    Text("アップグレード")
                    
                    let price = product?.price ?? 0
                    let displayPrice = product?.displayPrice ?? ""
                    let priceFormatStyle = product?.priceFormatStyle ?? Decimal.FormatStyle.Currency(code: "JPY")
                    Text(price, format: priceFormatStyle)
                    Text(displayPrice)
#endif
                    VStack(alignment: .leading) {
                        Text("アップグレードをすると次の機能が使えるようになります")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical)
                        
                        Group {
                            Text("イベント数の上限解除！")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom,3)
                            
                            Text("作成できるイベント数の上限が１個から無制限になります")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Image("upgrade1")
                                .padding()
                                .padding(.bottom, 30)
                        }
                        
                        Group {
                            Text("背景に画像を設定可能に！")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom,3)
                            
                            Text("あなただけのオリジナル背景を設定できます")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Image("upgrade2")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .padding(.bottom, 30)
                        }
                        
                        Group {
                            Text("様々な表示スタイルが選択可能に！")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom,3)
                            
                            Text("あなたの好きなデザインを選ぶことができます")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Image("upgrade3")
                                .padding()
                                .padding(.bottom, 30)
                        }
                        
                        Group {
                            Text("追加機能を先行招待！")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom,3)
                            
                            Text("アップデートによる追加機能を先行して利用することができます")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Image("upgrade4")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .padding(.bottom, 30)
                        }
                        
                    }
                    .padding()
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
            .frame(maxWidth: .infinity)
            .background(ColorUtility.backgroundary)
            
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
                }
                .padding()
                
                Button {
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .UpgradeViewTapPurchaseButton)
                    Task {
                        
                        /// 購入処理
                        await buy()
                    }
                } label: {
                    Text("購入ボタン")
                }
                .disabled(isPurchased)
                .frame(width: 200, height: 60)
                .foregroundStyle(.black)
                .background(Color.accentColor)
                .cornerRadius(30)
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
        UpgradeView()
            .environmentObject(store)
    }
}

enum ProductId: String {
    case `super` = "com.temporary.id"
    case premium = "premium"
}
