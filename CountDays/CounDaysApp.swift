//
//  CounDaysApp.swift
//  CounDays
//
//  Created by shoichiyamazaki on 2023/08/24.
//

import SwiftUI

@main
struct CountDaysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var viewModel = RealmViewModel()
    
    
    var body: some Scene {
        WindowGroup {
//            SettingView()
//            TestView2()
            MainView()
                .environmentObject(viewModel)
//            TestView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    /// 起動時処理
    /// Realmを登録する
    /// 通知許可
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        RealmViewModel().registerViewModel()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: .alert) { granted, error in
            if granted {
                print("Allowed")
            } else {
                print("Denied")
            }
        }
        
        return true
    }
}
