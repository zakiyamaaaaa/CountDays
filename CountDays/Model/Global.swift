//
//  Global.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/10/12.
//

import Foundation
import SwiftUI

struct Global {
    static let appUrl = "https://itunes.apple.com/jp/app/id6469093293?mt=8"
    static let localizationIds = ["ja", "en", "zh", "es"]
    static let language = Locale.current.language.languageCode?.identifier ?? "ja"
    static let localeID = Locale.current.identifier
}
