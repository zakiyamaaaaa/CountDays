//
//  CalendarView2.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/21.
//

import SwiftUI

struct CalendarView2: UIViewRepresentable {
    @Binding var dateSelected: Date
    let dateViewModel = DateViewModel()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        let dateComponents = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: dateViewModel.getYearNumber(date: dateSelected),
            month: dateViewModel.getMonthNumber(date: dateSelected),
            day: dateViewModel.getDayNumber(date: dateSelected)
            )
        view.selectionBehavior = selection
        view.backgroundColor = UIColor(ColorUtility.secondary)
        view.locale = Locale(identifier: "ja")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.visibleDateComponents = dateComponents
        selection.selectedDate = dateComponents
        
        return view
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        private let parent: CalendarView2
        
        init(_ parent: CalendarView2) {
            self.parent = parent
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents?.date ?? Date()
            print("selected")
            print(dateComponents?.date)
        }
        
    }
}

struct CalendarView2_Previews: PreviewProvider {
    @State static var selectedDatePreview: Date = Date()
    static var previews: some View {
        CalendarView2(dateSelected: $selectedDatePreview)
    }
}
