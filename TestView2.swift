//
//  TestView2.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/21.
//

import SwiftUI

struct TestView2: View {
    @State var selectedDate = Date()
    var dateViewModel = DateViewModel()
    
    var body: some View {
        VStack {
            HStack {
                
                Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                Text("\(dateViewModel.getDayText(date: selectedDate))日")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
            }
            
//            CalendarView(dateViewModel: dateViewModel)
//                .cornerRadius(20)
//                .padding()
//                .preferredColorScheme(.dark)
        }
    }
}

struct TestView2_Previews: PreviewProvider {
    static var previews: some View {
        TestView2()
    }
}
