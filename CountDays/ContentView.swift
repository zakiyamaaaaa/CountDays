//
//  ContentView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/14.
//

import SwiftUI

struct ContentView: View {
    init(){
           UITableView.appearance().backgroundColor = UIColor.gray
       }
       
       var body: some View {
           List{
               Text("要素1")
                   .foregroundColor(.black)
               Text("要素2")
               Text("要素3")
           }
           .background(.yellow)
           .scrollContentBackground(Visibility.hidden)
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
