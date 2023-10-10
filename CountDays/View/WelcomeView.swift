//
//  WelcomeView.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import SwiftUI

struct WelcomeView: View {
    @State private var opacity: Double = 0
    @State private var scaleFlag = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                BlurView(text: "Inspire", textSize: 38, startTime: 0.41)
                    .padding(.bottom, 5)
                BlurView(text: "Your Memory", textSize: 38, startTime: 1.85)
                    
                Text("App created by Shoichi Yamzaki")
                    .opacity(opacity)
                    .padding(.top, 30)
                    .animation(.easeIn(duration: 1).delay(4), value: opacity)
//                BlurView(text: "App created by Shoichi Yamzaki", textSize: 16, startTime: 3.76)
                        .padding(.top, 30)
            }
            .onAppear {
                opacity = 1
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                ZStack {
                    Button {
                        
                    } label: {
                        Text("")
                            .frame(width: 200, height: 60)
                            .background(.clear)
                            .cornerRadius(30)
                            .scaleEffect(1.1)
                            
                    }.overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.accentColor , lineWidth: 1)
                            .scaleEffect(1.0)
                            .opacity(scaleFlag ? 0 : 1)
                            .scaleEffect(scaleFlag ? 1.3 : 1.0)
                            
                            .animation(.easeIn(duration: 1.4).repeat(while: true, autoreverses: false), value: scaleFlag)
                            
                    }
                    .opacity(opacity)
                    .animation(.easeIn(duration: 1).delay(8), value: opacity)
                    
                    Button {
                        HapticFeedbackManager.play(.impact(.medium))
                        dismiss()
                    } label: {
                        Text("Get started")
                        
                            .frame(width: 200, height: 60)
                            .foregroundColor(.black)
                            .background(Color.accentColor)
                            .cornerRadius(30)
                            
                        
                    }
                    .buttonStyle(BounceButtonStyle())
                    .opacity(opacity)
                    .animation(.easeIn(duration: 1).delay(6), value: opacity)
                    .onAppear {
                        opacity = 1
                        scaleFlag.toggle()
                    }
                }
                
                Spacer()
            }
        }
        .interactiveDismissDisabled()
        .background(ColorUtility.primary)
        .analyticsScreen(name: String(describing: Self.self),
                               class: String(describing: type(of: self)))
        
    }
}

import struct SwiftUI.Animation

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
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
