//
//  FirebaseManager.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/14.
//

import Foundation
import FirebaseAnalytics
import FirebaseAnalyticsSwift

class FirebaseAnalyticsManager {
    static func recordEvent(analyticsKey: AnalyticsEventKey, content: String = "") {
        
        switch analyticsKey {
        case .UpgradeViewPurchase:
            Analytics.logEvent(AnalyticsEventPurchase, parameters: [
                AnalyticsParameterItemID: analyticsKey.state.id,
              AnalyticsParameterItemName: analyticsKey.state.name,
              AnalyticsParameterContentType: content,
            ])
        default:
            Analytics.logEvent(AnalyticsEventSelectItem, parameters: [
                AnalyticsParameterItemID: analyticsKey.state.id,
              AnalyticsParameterItemName: analyticsKey.state.name,
              AnalyticsParameterContentType: content,
            ])
        }
    }
}

enum AnalyticsEventKey: Int {
    /// メイン：イベント作成ボタンタップaaa
    case MainViewAddEvent
    /// メイン：イベント更新ボタンタップaaa
    case MainViewUpdateEvent
    /// メイン：設定ボタンタップaaaa
    case MainViewTapSettingButton
    /// 編集：イベント削除ボタンタップaaa
    case ConfigureViewDeleteEvent
    /// 編集：イベント削除アラートキャンセルタップaaa
    case ConfigureViewTapDeleteEventAlertCancel
    /// 編集：イベント削除アラート実行タップaaa
    case ConfigureViewTapDeleteEventAlertExecution
    /// 編集：中身の編集タップaaa
    case ConfigureViewTapConfigureContent
    /// 編集：スタイル編集タップaaa
    case ConfigureViewTapConfigureStyle
    /// 編集：背景編集タップaaa
    case ConfigureViewTapConfigureBackground
    /// 編集：テキスト編集タップaaa
    case ConfigureViewTapConfigureText
    /// 編集：閉じるボタンタップaaa
    case ConfigureViewTapCloseButton
    /// 編集：登録ボタンタップaaa
    case ConfigureViewTapRegisterButton
    /// 編集：イベント名ボタンタップaaa
    case ConfigureViewTapEventNameButton
    /// 編集：背景に画像を選択
    case ConfigureViewSelectBacgkroundImage
    /// 編集：スタイル変更のサークルビューでアップグレードのボタンタップ
    case ConfigureViewTapUpgradeFromCircleViewStyle
    /// 編集：スタイル変更のカレンダービューでアップグレードのボタンタップ
    case ConfigureViewTapUpgradeFromCalendarViewStyle
    /// 編集：背景に画像を選択
    case ConfigureViewSelecteBacgkroundImage
    /// アップグレード：購入ボタンタップaaa
    case UpgradeViewTapPurchaseButton
    /// アップグレード：購入するaaa
    case UpgradeViewPurchase
    /// アップグレード：復元ボタンタップaaa
    case UpgradeViewTapRestoreButton
    /// アップグレード：復元するaaa
    case UpgradeViewRestore
    /// 編集：日付編集ボタンタップaaa
    case ConfigureViewTapConfigureDateButton
    /// 日付編集：閉じるボタンタップ
    case ConfigureDateViewTapCloseButton
    /// 日付編集：OKボタンタップaaa
    case ConfigureDateViewTapOKButton
    /// 設定：アップグレードタップaaa
    case SettingViewTapUpgrade
    /// 設定：通知のトグルaaa
    case SettingViewToggleNotificatioin
    /// 設定：お問い合わせタップaaa
    case SettingViewTapMail
    /// 設定：共有タップaaa
    case SettingViewTapShareView
    /// 設定：プライバシーポリシータップaaa
    case SettingViewTapPrivacyPolicy
    /// 設定：規約タップaaa
    case SettingViewTapTerm
    /// 設定：すべてのイベントを消去aaa
    case SettingViewTapDeleteAllEvent
    /// 設定：すべてのイベントを消去するアラートをキャンセルaaa
    case SettingViewCancelAlertDeleteAllEvent
    /// 設定：すべてのイベントを消去するアラートを実行aaa
    case SettingViewExecuteAlertDeleteAllEvent
    /// イベント詳細設定：時間と分を表示トグルを操作
    case EventDetailConfigurationToggleDisplayHourAndMinute
    /// イベント詳細設定：秒を表示トグルを操作
    case EventDetailConfigurationToggleDisplaySecond
    
    
    var state: (id: String, name: String) {
        return (self.rawValue.description, String(describing: Self.self))
    }
}
