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
    @State private var selectingDate: Date
    @State private var isAllDayEvent = true
    @State private var editingHour = false
    @StateObject var dateViewModel: DateViewModel
    var daysList = Array(1...30)
    var hourList = Array(0...23)
    var minuteList = Array(0...59)
    @State var selectingMonthlyDay: Int = 1
    @State var selectingWeeklyDate: DayOfWeek = .sunday
    @Binding var selectedWeeklyDate: DayOfWeek
    @State var selectingHour: Int = 0
    @State var selectingMinute: Int = 0
    @State var selectedPopup = false
    
    init(eventType: Binding<EventType>, frequentType: Binding<FrequentType>, dateViewModel: StateObject<DateViewModel>, weeklyDate: Binding<DayOfWeek>) {
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
        
        let day = dateViewModel.wrappedValue.getDayNumber(date: dateViewModel.wrappedValue.selectedDate)
        
        _selectingMonthlyDay = State(initialValue: day)
        _selectingWeeklyDate = State(initialValue: weeklyDate.wrappedValue)
        _selectedWeeklyDate = weeklyDate
        _selectedFrequentType = frequentType
        _selectedEventType = eventType
        _dateViewModel = dateViewModel
        _selectingDate = State(initialValue: dateViewModel.wrappedValue.selectedDate)
//        _selectedDate = selectedDate
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { scrollValue in
                    
                    ScrollView {
                        
                        headerView
                        
                        VStack {
                            Picker("イベントタイプ", selection: $selectedEventType) {
                                
                                ForEach(EventType.allCases) {
                                    event in
                                    
                                    Text(event.rawValue)
                                        .tag(event)
                                    
                                    
                                }
                            }
                            .cornerRadius(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.black))
                            .padding()
                            .scaledToFill()
                            .pickerStyle(.segmented)
                            
                        }
                        
                        ZStack {
                            
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
                            .isHidden(hidden: selectedEventType == .countup)
                            
                            switch selectedEventType {
                            case .countdown:
                                
                                switch selectedFrequentType {
                                case .never, .annual:
                                    
                                    CalendarView(dateSelected: $selectingDate)
                                        .cornerRadius(20)
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
                            case .countup:
                                CalendarView(dateSelected: $selectingDate)
                                    .cornerRadius(20)
                                    .preferredColorScheme(.dark)
                                    .tint(selectedFrequentType.color)
                            }
                            
                            
                        }
                        
                        if !isAllDayEvent {
                            VStack() {
                                Text("時刻")
                                    .foregroundColor(.white)
                                let text = selectingHour.description + ":" + String(format: "%02d", selectingMinute)
                                
                                Button {
                                    withAnimation {
                                        editingHour.toggle()
                                        scrollValue.scrollTo("toggle")
                                    }
                                    
                                } label: {
                                    Text("\(text)")
                                }
                                .frame(width: 100, height: 50)
                                .border(editingHour ? .red : .clear)
                                .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.primary))
                                
                                if editingHour {
                                    
                                    TimePicker(hour: $selectingHour, minute: $selectingMinute)
                                        .background(ColorUtility.primary)
                                }
                                
                            }
                            .frame(width: 200, height: editingHour ? 350 : 100)
                            
                            .animation(nil, value: isAllDayEvent)
                            .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.secondary))
                            .padding()
                            
                        }
                        
                        Toggle("終日イベント", isOn: $isAllDayEvent.animation())
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(ColorUtility.secondary))
                            .padding()
                            .id("toggle")
                        
                        
                        Spacer()
                    }
                    .background(ColorUtility.backgroundary)
                }
            }
            
            
            if selectedPopup {
                ZStack {
                    HStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
                    .opacity(0.5)
                    
                    HStack {
                        Text("未来の日付を基準にカウントする場合、カウント日数がマイナスになっちゃうよ！！")
                            .foregroundColor(.black)
                            .padding()
                    }
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                }
                .onTapGesture {
                    if selectedPopup {
                        selectedPopup = false
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("イベント")
                    .foregroundColor(.white)
                let selectedDate = selectingDate
                switch selectedEventType {
                case .countdown:
                    Text("カウントダウン")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    HStack {
                        switch selectedFrequentType {
                        case .never:
                            if CalendarViewModel.isPastDate(selectedDate) && selectedEventType == .countdown{
                                Text("終了")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.red)
                            }
                            Text(dateViewModel.getYearText(date: selectedDate) + "年")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(dateViewModel.getDayText(date: selectedDate))日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        case .annual:
                            Text("毎年")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(dateViewModel.getDayText(date: selectedDate))日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        case .monthly:
                            Text("毎月")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(selectingMonthlyDay)日")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        case .weekly:
                            Text("毎週")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(selectingWeeklyDate.stringValue)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                case .countup:
                    Text("カウントアップ")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    HStack {
                        Text(dateViewModel.getYearText(date: selectedDate) + "年")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(dateViewModel.getDayText(date: selectedDate))日")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        
                        if !CalendarViewModel.isPastDate(selectedDate) {
                            Button {
                                withAnimation(.spring()) {
                                    /// ポップアップ表示
                                    selectedPopup.toggle()
                                }
                                
                            } label: {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .tint(.orange)
                            }
                        }
                    }
                }
                
                
            }
            .padding()
            
            Spacer()
            
            /// 設定を保存するところ
            Button {
                
                if selectedFrequentType == .weekly {
                    selectingDate = CalendarViewModel.getDateAtWeekly(dayAtWeek: selectingWeeklyDate)
                    selectedWeeklyDate = selectingWeeklyDate
                    dateViewModel.selectedDate = selectingDate
                } else {
                    dateViewModel.selectedDate = selectingDate
                    
                    dateViewModel.selectedDate = Calendar.current.date(bySettingHour: selectingHour, minute: selectingMinute, second: 0, of: selectingDate)!
                }
                
                
                
                dismiss()
            } label: {
                Image(systemName: "checkmark")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(ColorUtility.highlighted))
                    .tint(.white)
                    .padding()
            }
            
        }
        .background(ColorUtility.primary)
    }
    
    /// 毎月のカウントビュー
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
                ForEach(daysList, id: \.self) { day in
                    Button {
                        selectingMonthlyDay = day
                        selectingDate = Calendar.current.date(bySetting: .day, value: selectingMonthlyDay, of: selectingDate)!
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
    
    /// 曜日のカウントビュー
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
        .frame(maxHeight: .infinity)
    }
}

struct ConfigureDateView_Previews: PreviewProvider {
    @State static var frequent = FrequentType.never
    @State static var event: EventType = .countup
    @State static var weeklyDate: DayOfWeek = .sunday
    @StateObject static var dateViewModel = DateViewModel()
    static var previews: some View {
        ConfigureDateView(eventType: $event, frequentType: $frequent, dateViewModel: _dateViewModel, weeklyDate: $weeklyDate)
    }
}
