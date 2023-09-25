//
//  WidgetConfig.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/20.
//

import Foundation
import UIKit

enum WidgetConfig {
    case small
    case medium
    case large
    
    var size: CGSize {
        switch self {
        case .small:
            switch (screenSize.width, screenSize.height) {
            case (430, 932), (428, 926):
                return CGSize(width: 170, height: 170)
            case (414, 896):
                return CGSize(width: 169, height: 169)
            case (414, 736):
                return CGSize(width: 159, height: 159)
            case (393, 852), (390, 844):
                return CGSize(width: 158, height: 158)
            case (375, 812), (360, 780):
                return CGSize(width: 155, height: 155)
            case (375, 667):
                return CGSize(width: 148, height: 148)
            case (320, 568):
                return CGSize(width: 141, height: 141)
            default:
                return CGSize(width: 158, height: 158)
            }
        case .medium:
            switch (screenSize.width, screenSize.height) {
            case (430, 932), (428, 926):
                return CGSize(width: 364, height: 170)
            case (414, 896):
                return CGSize(width: 360, height: 169)
            case (414, 736):
                return CGSize(width: 348, height: 157)
            case (393, 852), (390, 844):
                return CGSize(width: 338, height: 158)
            case (375, 812), (360, 780):
                return CGSize(width: 329, height: 155)
            case (375, 667):
                return CGSize(width: 321, height: 148)
            case (320, 568):
                return CGSize(width: 292, height: 141)
            default:
                return CGSize(width: 338, height: 158)
            }
        case .large:
            switch (screenSize.width, screenSize.height) {
            case (430, 932), (428, 926):
                return CGSize(width: 364, height: 382)
            case (414, 896):
                return CGSize(width: 360, height: 379)
            case (414, 736):
                return CGSize(width: 348, height: 357)
            case (393, 852), (390, 844):
                return CGSize(width: 338, height: 354)
            case (375, 812), (360, 780):
                return CGSize(width: 329, height: 345)
            case (375, 667):
                return CGSize(width: 321, height: 324)
            case (320, 568):
                return CGSize(width: 292, height: 311)
            default:
                return CGSize(width: 158, height: 158)
            }
        }
    }
}

let screenSize = UIScreen.main.bounds.size
