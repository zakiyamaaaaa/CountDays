//
//  AddEventView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/16.
//

import SwiftUI

struct AddEventView: View {
    @State private var isPresented = false
    @State private var scale = false
    let width = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(ColorUtility.secondary)
                .widgetFrame()
                .cornerRadius(20)
            
            Text("+")
                .foregroundColor(.white)
                .font(.system(size:100))
                .baselineOffset(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
        }
        
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
