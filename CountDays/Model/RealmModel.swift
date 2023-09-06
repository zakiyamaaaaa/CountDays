//
//  EventModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/06/03.
//

import Foundation
import RealmSwift
import SwiftUI

/// イベントモデル
/// UserModel
/// id: ユーザーの一意なID
/// events: eventの集合体
///
/// EventModel
/// title: イベントタイトル
/// date: 設定する日付
/// textColor: テキストの色
/// backgroundColor: 背景色
/// displayStyle: 表示するスタイル
/// * widgetSize: ウィジェットのサイズ
/// * isFuture: 未来に対する日付かどうか
/// * backgroundImageURL: 背景画像URL
/// fontSize: テキストサイズ→TODO：サイズをenum的に複数選択しがあるほうがいい
/// * fontStyle: フォントスタイル
/// Model 定義
/// User
///         id: ユーザーの一意なID
///         events: 設定したイベント(eventモデルを参照)
///         event
///             title:タイトル
///             date:日付
///             textColor:テキストの色
///             backgroundColor:背景色
///             displayStyle: 表示スタイル
///             fontSize:文字サイズ
///

final class RealmModel: ObservableObject {
    /// TODO: スキーマバージョンを1になおす
    private static var config = Realm.Configuration(schemaVersion: 6)
    private static var realm = try! Realm(configuration: config)
    
    /// 保存されているuserを返す
    static var user: User {
        guard let a = realm.objects(User.self).first else {
            return User()
        }
        return a
    }
    
    /// 保存されているeventを返す
    static var events: Results<Event> {
        realm.objects(Event.self)
    }
    
    /// Userデータを登録する
    static func registerUser() {
        /// Userのデータがないかどうかチェック
        if realm.objects(User.self).first != nil {
            return
        }
        
        let user = User()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write({
            realm.add(user)
        })
    }
    
    
    /// Eventデータを登録
    static func registerEvent(event: Event) {
        try! realm.write {
            realm.add(event)
        }
    }
    
    /// Event データを更新
    static func updateEvent(event: Event) {
        try! realm.write {
            event.title = event.title
            event.date = event.date
        }
    }
    
    
    /// Event データを削除
    static func deleteEvent(event: Event) {
        try! realm.write {
            realm.delete(event)
        }
    }
    
    /// Event データすべて削除
    static func deleteAllEvents() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}

final class User: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var events: RealmSwift.List<Event>
    
//    init(id: String = UUID().uuidString, events: RealmSwift.List<Event>) {
//        self.id = id
//        self.events = events
//    }
}

class Event: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var title: String
    @Persisted var date: Date
//    @Persisted var textColor: RealmSwift.List<Double>
//    @Persisted var backgroundColor: RealmSwift.List<Double>
    @Persisted var textColor: TextColor
    @Persisted var backgroundColor: BackgroundColor
//    @Persisted(originProperty: "events") var user: LinkingObjects<User>
    @Persisted var displayStyle: EventDisplayStyle
    @Persisted var frequentType: FrequentType = .never
    @Persisted var eventType: EventType = .countup
    @Persisted var dayAtMonthly: Int = 1
//    @objc dynamic var imageData: NSData?
    @Persisted var imageData: Data?
    @Persisted var hour: Int = 0
    @Persisted var minute: Int = 0
    @Persisted var dayOfWeek: DayOfWeek = .sunday
    @Persisted var displayHour: Bool = true
    @Persisted var displayMinute: Bool = true
    @Persisted var displaySecond: Bool = false
    @Persisted var fontSize: Float
    let user = LinkingObjects(fromType: User.self, property: "events")
    
    override init() {
        
    }
    
    init(title: String, date: Date, textColor: TextColor, backgroundColor: BackgroundColor, displayStyle: EventDisplayStyle, fontSize: Float, frequentType: FrequentType = .never, eventType: EventType = .countup, dayAtMonthly: Int = 1, hour: Int = 0, minute: Int = 0, dayOfWeek: DayOfWeek = .sunday, displayHour: Bool = true, displayMinute: Bool = true, displaySecond: Bool = false, image: UIImage? = nil) {
        super.init()
        self.id = id
        self.title = title
        self.date = date
        self.frequentType = frequentType
        self.eventType = eventType
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.displayStyle = displayStyle
        self.fontSize = fontSize
        self.dayAtMonthly = dayAtMonthly
        self.hour = hour
        self.minute = minute
        self.dayOfWeek = dayOfWeek
        self.displayHour = displayHour
        self.displayMinute = displayMinute
        self.displaySecond = displaySecond
        
        /// 画像の変換処理。ファイルサイズをリサイズ
        if let image = image, let pngData = image.pngData(), let jpegData = image.resize().jpegData(compressionQuality: 0.8)  {
            
            print("ファイルサイズ")
            print(pngData.count)
            print(jpegData.count)
        
            self.imageData = jpegData
        }
    }
}

struct EventModel {
    var title: String
    var date: Date
    var textColor: Color
    var backgroundColor: Color
    var displayStyle: EventDisplayStyle
}

let mockEventModel = EventModel(title: "This is mock", date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(), textColor: .white, backgroundColor: .mint, displayStyle: .standard)
