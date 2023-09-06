//
//  AddEventView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/16.
//

import SwiftUI

struct AddEventView: View {
    @State private var isPresented = false
    let width = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(ColorUtility.secondary)
                .frame(width: width*1/3 + 10, height: width*1/3 + 10)
                .cornerRadius(30)
            VStack {
                Text("+")
                    .foregroundColor(.white)
                    .font(.system(size:100))
                Spacer()
            }
            .frame(width: width*2/5, height: width*1/3)
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
