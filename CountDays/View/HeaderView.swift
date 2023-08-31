//
//  HeaderView.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/08/31.
//

import SwiftUI

struct HeaderView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 35,weight: .bold))
                .padding()
            Spacer()
        }
        .foregroundColor(.white)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(ColorUtility.primary)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "ようこそ")
    }
}
