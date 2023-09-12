//
//  CalendarView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/05/28.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Binding var dateSelected: Date
    
//    @StateObject var dateViewModel: DateViewModel
    
    private let dateViewModel = DateViewModel()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
//        let dateSelected = dateSelected
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
        private let parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
//            parent.dateViewModel.selectedDate = dateComponents?.date ?? Date()
            parent.dateSelected = dateComponents?.date ?? Date()
        }
        
    }
}

struct CalendarView_Previews: PreviewProvider {
    @State static var selectedDatePreview: Date = Date()
    static var previews: some View {
        CalendarView(dateSelected: $selectedDatePreview)
    }
}
