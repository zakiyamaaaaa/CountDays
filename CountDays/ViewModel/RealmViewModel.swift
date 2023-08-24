//
//  RealmViewModel.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/07/23.
//

import Foundation
import RealmSwift

class RealmViewModel: ObservableObject {
    @Published var model: RealmModel = RealmModel()
    
    var events: Results<Event> {
        RealmModel.events
    }
    
    func registerViewModel(){
        self.objectWillChange.send()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        RealmModel.registerUser()
    }
    
    func registerEvent(event: Event) {
        self.objectWillChange.send()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        RealmModel.registerEvent(event: event)
    }
    
    func updateEvent(event: Event) {
        self.objectWillChange.send()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        RealmModel.updateEvent(event: event)
    }
    
    func deleteEvent(event: Event) {
        self.objectWillChange.send()
        RealmModel.deleteEvent(event: event)
    }
    
    func deleteAllEvents() {
        self.objectWillChange.send()
        RealmModel.deleteAllEvents()
    }
}

