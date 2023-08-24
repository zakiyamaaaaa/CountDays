//
//  EventDetailConfigurationView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/23.
//

import SwiftUI

struct EventDetailConfigurationView: View {
    @Binding var showHour: Bool
    @Binding var showMinute: Bool
    @State var showHourandMinute: Bool = true
    @Binding var showSecond: Bool
    
//    init(showHour: Binding<Bool>, showMinute: Binding<Bool>, showSecond: Binding<Bool>) {
//        self._showHour = showHour
//        self._showMinute = showMinute
//        self._showSecond = showSecond
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("イベント表示設定")
                .padding()
                .foregroundColor(.white)
                .font(.system(size: 30,weight: .bold))
            List {
                
                
                Toggle(isOn: $showHourandMinute) {
                    
                    Text("時間と分を表示")
                        .foregroundColor(.white)
                }.onChange(of: showHourandMinute, perform: { newValue in
                    showHour = newValue
                    showMinute = newValue
                    print(newValue)
                })
                .listRowBackground(Color.primary)
                
                Toggle(isOn: $showSecond) {
                    HStack {
                        
                        Image(systemName: "lock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 30)
                            .foregroundColor(.blue)
                        Text("秒数を表示")
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: showSecond, perform: { newValue in
                    showSecond = newValue
                })
                .listRowBackground(Color.primary)
            }
            
            .scrollContentBackground(.hidden)
            .background(ColorUtility.backgroundary)
        }
        .environment(\.defaultMinListRowHeight, 67)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorUtility.backgroundary)
        .onAppear{
            showHourandMinute = showHour && showMinute
        }
    }
}

struct EventDetailConfigurationView_Previews: PreviewProvider {
    @State static var a = true
    
    static var previews: some View {
        EventDetailConfigurationView(showHour: $a, showMinute: $a, showHourandMinute: a, showSecond: $a)
    }
}
