//
//  ConfigureDateView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/27.
//

import SwiftUI

struct ConfigureDateView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedEventType: EventType
    @Binding var selectedFrequentType: FrequentType
    @State private var alldayFlag = true
    @State private var selectingDate: Date
    @StateObject var dateViewModel: DateViewModel
    var daysList = Array(1...30)
//    @State var initialMonthlyDay = 1
    @State var selectingMonthlyDay: Int = 1
    @Binding var selectedMonthlyDay: Int
//    @State var initialWeeklyDate: DayOfWeek = .sunday
    @State var selectingWeeklyDate: DayOfWeek = .sunday
    @Binding var selectedWeeklyDate: DayOfWeek
    
    init(eventType: Binding<EventType>, frequentType: Binding<FrequentType>, dateViewModel: StateObject<DateViewModel>, monthlyDay: Binding<Int>, weeklyDate: Binding<DayOfWeek>) {
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
//        _initialMonthlyDay = State(initialValue: monthlyDay.wrappedValue)
//        _initialWeeklyDate = State(initialValue: weeklyDate.wrappedValue)
        _selectingMonthlyDay = State(initialValue: monthlyDay.wrappedValue)
        _selectingWeeklyDate = State(initialValue: weeklyDate.wrappedValue)
        _selectedMonthlyDay = monthlyDay
        _selectedWeeklyDate = weeklyDate
        _selectedFrequentType = frequentType
        _selectedEventType = eventType
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
                        Text("カウントダウン")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    case .countup:
                        Text("カウントアップ")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    
                    let selectedDate = selectingDate
                    
                    HStack {
                        
                        switch selectedFrequentType {
                        case .never:
                            Text(dateViewModel.getYearText(date: selectedDate) + "年")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text("\(dateViewModel.getDayText(date: selectedDate))日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                        case .annual:
                            Text("毎年")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text("\(dateViewModel.getDayText(date: selectedDate))日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                        case .monthly:
                            Text("毎月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text("\(selectingMonthlyDay)日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                        case .weekly:
                            Text("毎週")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                            Text(selectingWeeklyDate.stringValue)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                        }
                        
                        
                    }
                }
                .padding()
                
                Spacer()
                
                Button {
                    dateViewModel.selectedDate = selectingDate
                    
                    selectedWeeklyDate = selectingWeeklyDate
                    selectedMonthlyDay = selectedMonthlyDay
                    
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
            
            switch selectedFrequentType {
            case .never, .annual:
                    CalendarView(dateSelected: $selectingDate)
                        .cornerRadius(20)
                        .padding()
                        .preferredColorScheme(.dark)
                        .tint(selectedFrequentType.color)
            case .monthly:
                monthlyView
                    .preferredColorScheme(.dark)
                    .padding()
            case .weekly:
                weeklyView
                    .preferredColorScheme(.dark)
                    .padding()
            }

            
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
    
    private var monthlyView: some View {
        VStack {
            HStack {
                Spacer()
                Text("毎月のカウント日づけ")
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            
            Menu(selectingMonthlyDay.description + " 日") {
                ForEach(daysList.reversed(), id: \.self) { day in
                    Button {
                        selectingMonthlyDay = day
                    } label: {
                        Text(day.description)
                            .foregroundColor(.white)
                    }

                }
            }
            .tint(.white)
            .font(.system(size: 24))
            .frame(width: 150, height: 70)
            .background(RoundedRectangle(cornerRadius: 20).fill(ColorUtility.primary))
            .padding()
            
        }
        .background(ColorUtility.secondary)
        .cornerRadius(10)
    }
    
    private var weeklyView: some View {
        VStack {
            HStack {
                Spacer()
                Text("毎週のカウント曜日")
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            
            Menu(selectingWeeklyDate.stringValue) {
                ForEach(DayOfWeek.allCases.reversed(), id: \.self) { date in
                    Button {
                        selectingWeeklyDate = date
                    } label: {
                        Text(date.stringValue)
                            .foregroundColor(.white)
                    }

                }
            }
            .tint(.white)
            .font(.system(size: 24))
            .frame(width: 150, height: 70)
            .background(RoundedRectangle(cornerRadius: 20).fill(ColorUtility.primary))
            .padding()
            
        }
        .background(ColorUtility.secondary)
        .cornerRadius(10)
    }
        
}

struct ConfigureDateView_Previews: PreviewProvider {
    @State static var date = Date()
    @State static var frequent = FrequentType.monthly
    @State static var event: EventType = .countup
    @State static var monthlyDay = 1
    @State static var weeklyDate: DayOfWeek = .sunday
    @StateObject static var dateViewModel = DateViewModel()
    static var previews: some View {
        ConfigureDateView(eventType: $event, frequentType: $frequent, dateViewModel: _dateViewModel, monthlyDay: $monthlyDay, weeklyDate: $weeklyDate)
    }
}
