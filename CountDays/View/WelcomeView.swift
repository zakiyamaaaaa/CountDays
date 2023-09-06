//
//  WelcomeView.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import SwiftUI

struct WelcomeView: View {
    @State private var opacity: Double = 0
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                BlurView(text: "Inspire", textSize: 38, startTime: 0.41)
                    .padding(.bottom, 5)
                BlurView(text: "Your Memory", textSize: 38, startTime: 1.85)
                    
                BlurView(text: "App created by Shoichi Yamzaki", textSize: 16, startTime: 3.76)
                        .padding(.top, 30)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    opacity = 1.0
                }
            }
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Get started")
                        .frame(width: 200, height: 60)
                        .foregroundColor(.white)
                        .background(ColorUtility.highlighted)
                        .cornerRadius(30)
                        
                }
                .opacity(opacity)
                .animation(.easeIn(duration: 1).delay(7), value: opacity)
                .transition(.opacity)
                .onAppear {
                    opacity = 1
                }
                
                Spacer()
            }
        }
        
        .background(ColorUtility.primary)
        
    }
}

struct BlurView: View {
    let characters: Array<String.Element>
    let baseTime: Double
    let textSize: Double
    @State var blurValue: Double = 10
    @State var opacity: Double = 0

    init(text:String, textSize: Double, startTime: Double) {
        characters = Array(text)
        self.textSize = textSize
        baseTime = startTime
    }

    var body: some View {
        HStack(spacing: 1){
            ForEach(0..<characters.count) { num in
                Text(String(self.characters[num]))
                    .font(.custom("HiraMinProN-W3", fixedSize: textSize))
                    .blur(radius: blurValue)
                    .opacity(opacity)
                    .animation(.easeInOut.delay( Double(num) * 0.15 ), value: blurValue)
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + baseTime) {
                if blurValue == 0{
                    blurValue = 10
                    opacity = 0.01
                } else {
                    blurValue = 0
                    opacity = 1
                }
            }
        }
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
