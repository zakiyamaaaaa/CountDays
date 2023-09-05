//
//  SettingView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var store: Store
    @State var allowNotification = true
    @State private var isTermView = false
    @State private var isPrivacyView = false
    @State private var isInquiry = false
    @State private var isDeleteAllEvent = false
    @State private var showUpgradeView = false
    
    init() {
        
    }
 
    var body: some View {
        settingView
    }
    
    private var settingView: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("アップグレード")
                            .font(.system(size: 20))
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .onTapGesture {
                        showUpgradeView.toggle()
                    }
                }
                
                HStack {
                    Button {
                        /// 設定している通知を確認
                        NotificationCenter.confirmNotification()
                        
                    } label: {
                        Image(systemName: "bell.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text("通知")
                        .font(.system(size: 20))
                    
                    Spacer()
                    Toggle(isOn: $allowNotification) {
                        
                    }
                }.listRowBackground(ColorUtility.secondary)
                
                Section {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("すべてのイベントを削除")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isDeleteAllEvent.toggle()
                    }
                    
                }.alert("すべてのイベントを\n削除しますか", isPresented: $isDeleteAllEvent) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("キャンセル")
                    }
                    
                    Button(role: .destructive) {
                        RealmViewModel().deleteAllEvents()
                        NotificationCenter.removeAllNotification()
                    } label: {
                        Text("OK")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "paperplane.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("お問い合わせ")
                            .font(.system(size: 20))
                        
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        #if targetEnvironment(simulator)
                        #else
                            isInquiry.toggle()
                        #endif
                    }
                }
                
                Section("プライバシー") {
                    
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("プライバシーポリシー")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPrivacyView.toggle()
                    }
                    
                    HStack {
                        Image(systemName: "doc.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            
                        Text("利用規約")
                            .font(.system(size: 20))
                            
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTermView.toggle()
                    }
                    
                    
                }.sheet(isPresented: $isTermView) {
                    TermView()
                }.sheet(isPresented: $isPrivacyView) {
                    PrivacyPolicyView()
                }.sheet(isPresented: $isInquiry) {
                    MailView()
                }.sheet(isPresented: $showUpgradeView) {
                    UpgradeView()
                }
            }
            .padding()
            .foregroundColor(.white)
            .scrollContentBackground(.hidden)
            .background(ColorUtility.backgroundary)
            .navigationTitle("設定")
            .environment(\.defaultMinListRowHeight, 67)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground( Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .notDetermined, .provisional, .ephemeral:
                    allowNotification = true
                case .denied:
                    allowNotification = false
                @unknown default:
                    allowNotification = true
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    @StateObject static var store = Store()
    static var previews: some View {
        SettingView()
            .environmentObject(store)
    }
}
