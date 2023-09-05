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
                    Text("アップグレード")
                    
                    let price = product?.price ?? 0
                    let displayPrice = product?.displayPrice ?? ""
                    let priceFormatStyle = product?.priceFormatStyle ?? Decimal.FormatStyle.Currency(code: "JPY")
                    Text(price, format: priceFormatStyle)
                    Text(displayPrice)
                    
                    
                    Text("アップグレードをすると次の機能が使えるようになります")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("作成できるイベント数が１個までだったのが無制限に！")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("イベントの背景に画像を設定可能に！")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("カウントに秒数を表示可能に！")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                    Text("アップデートの追加機能を先行招待！")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .task {
//                guard let product = try? await viewModel.fetchProducts(productID).first else { return }
//                    viewModel.product = product
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
                    
                    if isPurchased {
                        /// 購入復元処理
                        Task {
                            try? await AppStore.sync()
                        }
                    } else {
                        isShowRestoreAlert.toggle()
                    }
                } label: {
                    Text("購入を復元")
                }
                .padding()

                Button {
                    Task {
                        
                        /// 購入処理
                        await buy()
                    }
                } label: {
                    Text("購入ボタン")
                }
                .disabled(isPurchased)
                .frame(width: 200, height: 60)
                .background(.mint)
                .cornerRadius(30)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(ColorUtility.secondary)
            .alert("購入記録がありません", isPresented: $isShowRestoreAlert) {
                Button("OK") {
                    
                }
            }
        }
    }
    
    func buy() async {
        do {
            if let product = product, try await self.store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
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
