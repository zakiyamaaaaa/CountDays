//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by shoichiyamazaki on 2023/09/20.
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        WidgetExtension()
        WidgetExtensionLiveActivity()
    }
}
