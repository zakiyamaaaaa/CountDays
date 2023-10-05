//
//  CountDaysApp.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/08/24.
//

import SwiftUI
import RealmSwift
import Combine
import FirebaseCore
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import WidgetKit

@main
struct CountDaysApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var viewModel = RealmViewModel()
    @StateObject var store = Store()
    
    
    var body: some Scene {
        WindowGroup {
//            TestView4()
//            WelcomeView()
//            ContentView()
//            SettingView()
//            TestView3()
            MainView()
                .environmentObject(viewModel)
                .environmentObject(store)
//            TestView()
//            TestView2(model: TestViewModel(textTitle: "hoge"))
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
            
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == "WidgetExtension" {
            print("Launch from Widget Kit")
            WidgetCenter.shared.reloadAllTimelines()
        }
        return true
    }
}
