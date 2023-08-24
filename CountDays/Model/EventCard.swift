//
//  EventCard.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import Foundation
import SwiftUI

struct EventCard: Identifiable {
    var id = UUID()
    var title: String
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var style: EventDisplayStyle
    var backgroundColor: Color
    var textColor: Color
}

//struct RowView: View {
//    let cards: [EventCard]
//    let width: CGFloat
//    let height: CGFloat
//    let horizontalSpacing: CGFloat
//    var body: some View {
//        VStack {
//            ForEach(cards) { card in
//                EventCardView(title: card.title, day: card.day, hour: card.hour, minute: card.minute, style: .standard, backgroundColor: .primary, textColor: .white)
//                
//            }
//        }
//        .padding()
//    }
//}
