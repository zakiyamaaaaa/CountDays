//
//  CountDaysWidgetBundle.swift
//  CountDaysWidget
//
//  Created by shoichiyamazaki on 2023/08/24.
//

import WidgetKit
import SwiftUI

@main
struct CountDaysWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountDaysWidget()
        CountDaysWidgetLiveActivity()
    }
}
