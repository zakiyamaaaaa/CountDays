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
///             displaySize: 表示するイベントのサイズ（まだ未実装）
///             frequentType: 頻度のタイプ
///             eventType: イベントのタイプ
///             fontSize:文字サイズ
///             displayLang: イベントに表示する文字言語
///

final class RealmModel: ObservableObject {
    /// TODO: スキーマバージョンを1になおす
    static var config = Realm.Configuration(schemaVersion: 5)
    static var realm: Realm {
        config.fileURL = fileUrl
        print("schema: \(config.schemaVersion)")
        return try! Realm(configuration: config)
    }
    
    static var fileUrl: URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.countdays.dev")!
        return url.appending(path: "db.realm")
    }
    
    /// 保存されているuserを返す  
    static var user: User {
        return realm.objects(User.self).first ?? User()
    }
    
    /// 保存されているeventを返す
    static var events: Results<Event> {
        realm.objects(Event.self)
    }
    
    /// Userデータを登録する
    static func registerUser() {
//        let config = Realm.Configuration(schemaVersion: 1)
//        Realm.Configuration.defaultConfiguration = config
        /// Userのデータがないかどうかチェック
//        let realm = try! Realm()
        if realm.objects(User.self).first != nil {
            return
        }
        
        let user = User()
        user.createdDate = Date()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        try! realm.write({
            realm.add(user)
        })
    }
    
    /// 通知の許可変数を更新
    static func updateNotificationStatus(status: Bool) {
        try! realm.write({
            user.allowNotification = status
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
//        if let eventThaw = event.thaw() {
            try! realm.write {
                realm.add(event, update: .modified)
                
                //            event.title = event.title
                //            event.title = "update"
                //            event.date = event.date
            }
//        }
    }
    
    
    /// Event データを削除
    static func deleteEvent(event: Event) {
        
        if let thawedEvent = event.thaw(), !thawedEvent.isInvalidated {
            try! thawedEvent.realm?.write {
                thawedEvent.realm?.delete(thawedEvent)
            }
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
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var createdDate: Date
    @Persisted var allowNotification: Bool = false
    @Persisted var events: RealmSwift.List<Event>
    
//    init(id: String = UUID().uuidString, events: RealmSwift.List<Event>) {
//        self.id = id
//        self.events = events
//    }
}

class Event: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: UUID
    
    @Persisted var title: String
    @Persisted var date: Date
//    @Persisted var textColor: RealmSwift.List<Double>
//    @Persisted var backgroundColor: RealmSwift.List<Double>
    @Persisted var textColor: TextColor
    @Persisted var backgroundColor: BackgroundColor
//    @Persisted(originProperty: "events") var user: LinkingObjects<User>
    @Persisted var displayStyle: EventDisplayStyle
    @Persisted var displaySize: Int
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
    @Persisted var displayLang: DisplayLang
    @Persisted var createdDate: Date = Date()
    @Persisted var updatedDate: Date = Date()
    /// サークルビューの１周辺りの単位
    /// 初期値は100日= 60*60*24
    @Persisted var unitOfCircle: Int = 60*60*24*100
    
    var image: UIImage? {
        if let imageData {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    
    let user = LinkingObjects(fromType: User.self, property: "events")
    
    override init() {
        
    }
    
    init(id:UUID = UUID(), title: String, date: Date, textColor: TextColor, backgroundColor: BackgroundColor, displayStyle: EventDisplayStyle, fontSize: Float, displaySize: Int = 0, frequentType: FrequentType = .never, eventType: EventType = .countup, dayAtMonthly: Int = 1, hour: Int = 0, minute: Int = 0, dayOfWeek: DayOfWeek = .sunday, displayHour: Bool = true, displayMinute: Bool = true, displaySecond: Bool = false, image: UIImage? = nil, displayLang: DisplayLang = .jp) {
        super.init()
        self._id = id
        self.title = title
        self.date = date
        self.displaySize = displaySize
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
        self.displayLang = displayLang
        /// 画像の変換処理。ファイルサイズをリサイズ
        if let image, let pngData = image.pngData(), let jpegData = image.resize().jpegData(compressionQuality: 0.8)  {
            
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
