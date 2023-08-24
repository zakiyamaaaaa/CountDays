//
//  TestView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/05.
//

import SwiftUI

struct TestView: View {
    @State private var isShow = false
    @State private var isShowConfigured = false
    @State var number = 0
    @EnvironmentObject var viewModel: RealmViewModel
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 30)),
        GridItem(.flexible()),
    ]
    let itemPerRow: CGFloat = 5
    let horizontalSpacing: CGFloat = 15
    let numbers = [1,2,3,4,5,6,7,8,9]
    var body: some View {
        VStack {
            HStack {
                Text("イベント")
                    .padding()
                Spacer()
                Button("設定") {
                    
                }
                    .padding()
            }
            .foregroundColor(.white)
            .frame(height: 80)
            .background(ColorUtility.secondary)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    
//                    var cards = $mock.cards
                    
                    ForEach(0 ..< numbers.count, id: \.self) { i in
                        VStack {
                            Text("\(numbers[i])")
                                .frame(width: 180, height: 100)
                                .background(Color.white)
                                .onTapGesture {
                                    isShow.toggle()
                                    self.number = numbers[i]
                                }
                        }
                    }
                }.sheet(isPresented: $isShow) {
                    aaa(number: self.$number)
                }
            }
            .background(ColorUtility.backgroundary)
            
            Spacer()
        }
        .background(ColorUtility.backgroundary)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
