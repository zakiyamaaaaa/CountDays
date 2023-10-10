//
//  HapticFeedback.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import Foundation
import AudioToolbox
import UIKit

enum ImpactFeedbackStyle: Int {
    case light
    case medium
    case heavy
    case soft
    case rigid

    var value: UIImpactFeedbackGenerator.FeedbackStyle {
        return .init(rawValue: rawValue)!
    }

}

enum NotificationFeedbackType: Int {
    case success
    case failure
    case error

    var value: UINotificationFeedbackGenerator.FeedbackType {
        return .init(rawValue: rawValue)!
    }

}

enum Haptic {
    case impact(_ style: ImpactFeedbackStyle, intensity: CGFloat? = nil)
    case notification(_ type: NotificationFeedbackType)
}

final class HapticFeedbackManager {

    static func play(_ haptic: Haptic) {
        switch haptic {
        case .impact(let style, let intensity):
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style.value)
            impactFeedbackGenerator.prepare()
            
            if let intensity = intensity {
                impactFeedbackGenerator.impactOccurred(intensity: intensity)
            } else {
                impactFeedbackGenerator.impactOccurred()
            }
            
        case .notification(let type):
            let  notificationFeedbackGenerator = UINotificationFeedbackGenerator()
            notificationFeedbackGenerator.prepare()
            notificationFeedbackGenerator.notificationOccurred(type.value)
        }
        
    }
}
