//
//  VersionUpCheck.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import Foundation

struct VersionUpNotice {
    private let appleId = "hogehoge"
    
    func fire() {
        guard let url = URL(string: "https://itunes.apple.com/jp/lookup?id=\(appleId)") else { return }
        
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                   guard let data = data else {
                       return
                   }
        
                   do {
                       let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                       guard let storeVersion = ((jsonData?["results"] as? [Any])?.first as? [String : Any])?["version"] as? String,
                             let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                           return
                       }
                       switch storeVersion.compare(appVersion, options: .numeric) {
                       case .orderedDescending:
                           DispatchQueue.main.async {
//                               self.showAlert()
                           }
                           return
                       case .orderedSame, .orderedAscending:
                           return
                       }
                   }catch {
                   }
               })
               task.resume()
        
    }
}
