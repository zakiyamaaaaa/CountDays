//
//  TestView4.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/10/02.
//

import SwiftUI
import RealmSwift
import Algorithms

struct TestView4: View {
    
    @ObservedResults(Owner.self) var owner
    
    @State var editFlag = false
//    @ObservedRealmObject var selectDog: Dog = Dog()
    @State var selecteIndex = 0
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            if let owner = owner.first {
                Text("Owner Name")
                Text(owner.name)
                Text("Dog Name")
                ForEach(owner.dogs.indexed(), id:\.index) {index, dog in
                    VStack {
                        Button(action: {
                            editFlag.toggle()
//                            selectDog = dog
                            selecteIndex = index
                        }, label: {
                            
                            Text("編集")
                            
                            
                        })
                        TestViewRect(vm: DogViewModel(dog: dog))
                    }
                }
                
            }
        }
        .onAppear {
            TestRealmModel.createOwner()
        }
        .sheet(isPresented: $editFlag) { [selecteIndex] in
            if let selectDog = owner.first?.dogs[selecteIndex] {
                TestView4Sub(dog: selectDog)
            }
        }
    }
    
}

//#Preview {
//    TestView4(selectDog: Dog())
//}

struct TestView4Sub: View {
    
    @Environment(\.dismiss) var dismiss
//    @Binding var dog: Dog
//    @ObservedRealmObject var dog: Dog
//    @Binding var name: String
    @ObservedRealmObject var dog: Dog
    
    var body: some View {
        TestViewRect(vm: DogViewModel(dog: dog))
        
        Button(action: {
            dismiss()
            let updateDog = Dog()
            updateDog.name = "hoge4"
            updateDog._id = dog._id
//            dog.name = "kkk"
            
            TestRealmModel.updateName(dog: updateDog)
        }, label: {
            Text("変更する")
        })
        
        Button(action: {
            dismiss()
            TestRealmModel.deleteDog(dog: dog)
        }, label: {
            Text("削除する")
                .foregroundStyle(.red)
        })
    }
}

struct TestViewRect: View {
    let vm: DogViewModel
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width:100, height: 100)
                .foregroundStyle(Color.accentColor)
            Text(vm.name)
        }
    }
    
}

final class TestRealmModel: ObservableObject {
    static var config = Realm.Configuration(schemaVersion: 0)
    static var realm: Realm {
//        config.fileURL = fileUrl
        print("schema: \(config.schemaVersion)")
        return try! Realm(configuration: config)
    }
    
    static var fileUrl: URL {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.countdays.test.realm.dev")!
        return url.appending(path: "db.realm")
    }
    
    static func createOwner() {
        
        if realm.objects(Owner.self).first != nil {
            return
        }
        
        let owner = Owner()
        owner.name = "Hiroshi"
        
        let dog: Dog = Dog(name: "First", sex: true)
        owner.dogs.append(dog)
        
        let dog2 = Dog(name: "Second", sex: true)
        owner.dogs.append(dog2)
        
        let dog3 = Dog(name: "Third", sex: true)
        
        owner.dogs.append(dog3)
        
        try! realm.write {
            realm.add(owner)
        }
    }
    
    static func updateName(dog: Dog) {
        try! realm.write {
//            dog.thaw()?.name = "hoge"
            realm.add(dog, update: .modified)
        }
    }
    
    static func deleteDog(dog: Dog) {
        
        
        
        if let thawDog = dog.thaw(), thawDog.isInvalidated == false {
            try! thawDog.realm?.write {
                thawDog.realm?.delete(thawDog)
            }
        }
//        try! realm.write {
//            realm.delete(dog)
//        }
    }
}

final class Owner: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var dogs: RealmSwift.List<Dog>
}

class DogViewModel: ObservableObject {
    @Published var name: String
    @Published var sex: Bool
    
    init(dog: Dog) {
        self.name = dog.name
        self.sex = dog.sex
    }
}

class Dog: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var name: String
    @Persisted var sex: Bool
    
    override init() {
        
    }
    
    init(_id: UUID = UUID(), name: String, sex: Bool) {
        super.init()
        self._id = _id
        self.name = name
        self.sex = sex
    }
    
}
