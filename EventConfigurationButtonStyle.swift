//
//  EventConfigurationButton.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/06/01.
//

import SwiftUI

struct EventConfigurationButtonStyle: ButtonStyle {
    @Binding var active: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 50, height: 50)
            .foregroundColor(active ? .accentColor : .white)
            .font(.system(size: 30))
            .background(active ? ColorUtility.active : ColorUtility.inActive)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut, value: 0.2)
            .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(active ? Color.accentColor : .clear, lineWidth: 2)
            )
    }
}
