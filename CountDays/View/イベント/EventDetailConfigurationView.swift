//
//  EventDetailConfigurationView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/23.
//

import SwiftUI
import StoreKit

struct EventDetailConfigurationView: View {
    
    @EnvironmentObject var store: Store
    @Binding var showHour: Bool
    @Binding var showMinute: Bool
    @Binding var displayLang: DisplayLang
    @State var showHourandMinute: Bool = true
    @Binding var showSecond: Bool
    @State private var isPurchased = false
    @State private var product: Product?
    @State private var isShowUpgradeAlert = false
    @State private var isShowUpgradeView = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("イベント表示設定")
                .padding()
                .foregroundColor(.white)
                .font(.system(size: 30,weight: .bold))
            List {
                
                
                Toggle(isOn: $showHourandMinute) {
                    
                    Text("時間と分を表示")
                        .foregroundColor(.white)
                }.onChange(of: showHourandMinute, perform: { newValue in
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .EventDetailConfigurationToggleDisplayHourAndMinute, content: newValue.description)
                    showHour = newValue
                    showMinute = newValue
                    print(newValue)
                })
                .listRowBackground(Color.primary)
                
                Toggle(isOn: $showSecond) {
                    HStack {
                        
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 30)
                            .foregroundColor(.blue)
                        Text("秒数を表示")
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    if !isPurchased {
                        showSecond = false
                    }
                }
                .onChange(of: showSecond, perform: { newValue in
                    FirebaseAnalyticsManager.recordEvent(analyticsKey: .EventDetailConfigurationToggleDisplaySecond, content: newValue.description)
                    if newValue && isPurchased {
                        showSecond = true
                    } else if newValue && !isPurchased {
                        isShowUpgradeAlert.toggle()
                    } else if !newValue && isPurchased {
                        showSecond = false
                    }
                })
                .listRowBackground(Color.primary)
                
            }
            .task {
                guard let product = try? await store.fetchProducts(ProductId.super.rawValue).first else { return }
                self.product = product
                do {
                    try await self.isPurchased = store.isPurchased(product)
                    showSecond = isPurchased
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
            .onAppear {
                print("Apeear")
            }
            .alert("アップグレードが必要です", isPresented: $isShowUpgradeAlert) {
                Button("OK") {
                    isShowUpgradeView.toggle()
                }
            }
            .sheet(isPresented: $isShowUpgradeView, onDismiss: {
                showSecond = false
            }, content: {
                UpgradeView()
            })
            .scrollContentBackground(.hidden)
            .background(ColorUtility.backgroundary)
        }
        .environment(\.defaultMinListRowHeight, 67)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorUtility.backgroundary)
        .onAppear{
            showHourandMinute = showHour && showMinute
        }
        .analyticsScreen(name: String(describing: Self.self),
                               class: String(describing: type(of: self)))
    }
}

struct EventDetailConfigurationView_Previews: PreviewProvider {
    @State static var a = true
    @State static var b: DisplayLang = .jp
    @StateObject static var store = Store()
    static var previews: some View {
        EventDetailConfigurationView(showHour: $a, showMinute: $a, displayLang: $b, showHourandMinute: a, showSecond: $a).environmentObject(store)
    }
}
