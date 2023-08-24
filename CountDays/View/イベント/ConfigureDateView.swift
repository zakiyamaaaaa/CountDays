//
//  ConfigureDateView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/27.
//

import SwiftUI

struct ConfigureDateView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedEventType = EventType.countdown
    @State private var selectedFrequentType = FrequentType.never
    @State private var alldayFlag = true
    @State private var selectingDate: Date
    @StateObject var dateViewModel: DateViewModel
    
    init(dateViewModel: StateObject<DateViewModel>) {
        let font = UIFont.systemFont(ofSize: 20)

            // 選択中のセグメントの色
//            UISegmentedControl.appearance().selectedSegmentTintColor = foregroundColor

            // 背景色
//            UISegmentedControl.appearance().backgroundColor = backgroundColor

            // 通常時のフォントと前景色
            UISegmentedControl.appearance().setTitleTextAttributes([
                .font: font,
//                .foregroundColor: foregroundColor,
            ], for: .normal)

            // 選択時のフォントと前景色
            UISegmentedControl.appearance().setTitleTextAttributes([
                .font: font,
//                .foregroundColor: UIColor.white,
            ], for: .selected)
        _dateViewModel = dateViewModel
        _selectingDate = State(initialValue: dateViewModel.wrappedValue.selectedDate)
//        _selectedDate = selectedDate
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("イベント")
                    
                    switch selectedEventType {
                    case .countdown:
                        Text("日付")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    case .countup:
                        Text("カウントアップ")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                }
                .padding()
                
                Spacer()
                VStack {
                    let selectedDate = selectingDate
                    Text(dateViewModel.getYearText(date: selectedDate))
                    HStack {
                        
                        Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                        Text("\(dateViewModel.getDayText(date: selectedDate))日")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                    }
                }
                Spacer()
                
                Button {
                    dateViewModel.selectedDate = selectingDate
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(ColorUtility.highlighted))
                        .tint(.white)
                        .padding()
                }

            }
            
            Picker("イベントタイプ", selection: $selectedEventType) {
                ForEach(EventType.allCases) {
                    event in
                    Text(event.rawValue)
                        .lineLimit(2)
                        .tag(event)
                        .padding()
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .padding(.horizontal, 30)
            .listSectionSeparatorTint(.red)
            .tint(.red)
            .fixedSize()
            
            
            HStack {
                Menu(selectedFrequentType.rawValue) {
                    ForEach(FrequentType.allCases) {
                        frequent in
                        
                        Button(role: .none) {
                            selectedFrequentType = frequent
                        } label: {
                            Label(frequent.rawValue, systemImage:  selectedFrequentType == frequent ? "checkmark" : "none")
                            
                        }
                    }
                }
                .tint(.white)
                .padding()
            }
            .border(selectedFrequentType == .never ? .clear : selectedFrequentType.color, width: 5)
            .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.primary))
            
//            CalendarView(dateViewModel: dateViewModel)
            CalendarView(dateSelected: $selectingDate)
                .cornerRadius(20)
                .padding()
                .preferredColorScheme(.dark)
                .tint(selectedFrequentType.color)

            
            HStack {
                Toggle("終日イベント", isOn: $alldayFlag)
                    .padding()
            }
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.secondary))
            .padding()
            
            
            Spacer()
        }
        .background(ColorUtility.backgroundary)
    }
        
}

struct ConfigureDateView_Previews: PreviewProvider {
    @State static var date = Date()
    @StateObject static var dateViewModel = DateViewModel()
    static var previews: some View {
        ConfigureDateView(dateViewModel: _dateViewModel)
//        ConfigureDateView(selectedDate: $date)
    }
}
