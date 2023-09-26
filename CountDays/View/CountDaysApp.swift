//
//  CountDaysApp.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/08/24.
//

import SwiftUI
import RealmSwift
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift

@main
struct CountDaysApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var viewModel = RealmViewModel()
    @StateObject var store = Store()
    
    
    var body: some Scene {
        WindowGroup {
//            WelcomeView()
//            ContentView()
//            SettingView()
//            TestView3()
            MainView()
                .environmentObject(viewModel)
                .environmentObject(store)
//            TestView()
        }
    }
}

enum RealmMigrator {
  static private func migrationBlock(
    migration: Migration,
    oldSchemaVersion: UInt64
  ) {
    if oldSchemaVersion < 2 {
        // 変更点とか書くところ
    }
  }

  static func setDefaultConfiguration() {
    let config = Realm.Configuration(
      schemaVersion: 3,
      migrationBlock: migrationBlock)
    Realm.Configuration.defaultConfiguration = config
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
        
        FirebaseApp.configure()
        return true
    }
}