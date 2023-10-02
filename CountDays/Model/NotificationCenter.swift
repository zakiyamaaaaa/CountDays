//
//  NotificationCenter.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import Foundation
import Combine
import UserNotifications

class NotificationCenter {
    
    /// 通知許可の状態を取得    
    static func checkNotificationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { setting in
                continuation.resume(returning: setting.authorizationStatus)
            }
        }
    }
    
    /// 通知許可をリクエスト
    static func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: .alert) { granted, error in
            if granted {
                print("Allowed")
            } else {
                print("Denied")
            }
        }
        /// TODO:- 通知の切り替えは設定画面からもできますよページ表示
    }
    
    /// 通知の登録処理
    static func registerNotification(event: Event) {
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.date.description
        
        // こっちではなぜかうまくいかない
//        var components = Calendar.current.dateComponents(in: TimeZone.current, from: event.date)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: event.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: event._id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        print("次の内容で通知登録しました")
        print("id:\(request.identifier)")
        print("通知日付：\(components)")
    }
    
    /// 通知を削除
    static func removeNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// 通知をすべて削除
    static func removeAllNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    /// 登録している通知の確認
    static func confirmNotification() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { notifications in
            print("Count:\(notifications.count)")
            notifications.forEach { notification in
                debugPrint(notification.description)
            }
        }
    }
    
    
    static func sendNotificationRequest() {
        let content = UNMutableNotificationContent()
        content.title = "通知のタイトル"
        content.body = "通知の内容"
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let dateComponent = DateComponents(year: 2023, month: 8, day: 22, hour: 13, minute: 30)
        var dateComponent = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        dateComponent.second! += 10
        print(dateComponent)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
