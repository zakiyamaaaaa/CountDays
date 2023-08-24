//
//  AddEventButton.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/31.
//

import SwiftUI

struct AddEventButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            
    }
}
