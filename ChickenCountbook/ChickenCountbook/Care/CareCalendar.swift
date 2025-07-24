import SwiftUI

struct CareCalendar: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var reminderManager: ReminderManager
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var temporaryCompletedIds: Set<UUID> = []
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let taskColors: [Color] = [.green, .blue, .purple, .orange, .teal]
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 50 : 100)
                    .overlay(
                        HStack {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 17))
                                    .padding(.leading)
                            }
                            
                            Spacer()
                            
                            Text("Care calendar")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Color.clear
                                .frame(width: 30)
                        }
                            .padding(.top, ScreenConstants.smallScreen ? 0 : 30)
                        , alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            VStack(spacing: 20) {
                calendarView
                    .padding(.horizontal, 20)
                
                ScrollView {
                    remindersForSelectedDate
                        .padding(.horizontal, 20)
                }
                
                Button {
                    saveCompletedReminders()
                } label: {
                    Text(areAllRemindersActuallyCompleted() ? "All done" : "Save")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .disabled(areAllRemindersActuallyCompleted() && temporaryCompletedIds.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 10)
            }
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: selectedDate) { _ in
            resetTemporaryCompletedIds()
        }
    }
    
    private var calendarView: some View {
        VStack(spacing: 10) {
            HStack {
                Text(monthYearString(from: currentMonth))
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button {
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(extractDates()) { value in
                    if value.day != -1 {
                        Button {
                            selectedDate = value.date
                            resetTemporaryCompletedIds()
                        } label: {
                            ZStack {
                                if hasReminderOnDate(date: value.date) {
                                    Circle()
                                        .fill(getRandomColorForDate(date: value.date))
                                        .frame(width: 35, height: 35)
                                } else if Calendar.current.isDate(value.date, inSameDayAs: selectedDate) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 35, height: 35)
                                } else if Calendar.current.isDate(value.date, inSameDayAs: Date()) {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 35, height: 35)
                                }
                                
                                Text("\(value.day)")
                                    .foregroundColor(
                                        Calendar.current.isDate(value.date, inSameDayAs: selectedDate) ||
                                        hasReminderOnDate(date: value.date) ||
                                        Calendar.current.isDate(value.date, inSameDayAs: Date()) ? .white : .black
                                    )
                            }
                        }
                        .frame(height: 40)
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var remindersForSelectedDate: some View {
        VStack(spacing: 10) {
            ForEach(filteredReminders()) { reminder in
                HStack {
                    Image("diamondIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text(reminder.text)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if isReminderTemporarilyCompleted(reminder) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .onTapGesture {
                    toggleTemporaryCompletion(reminder: reminder)
                }
            }
            
            if filteredReminders().isEmpty {
                Text("No reminders for this date")
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
            
            Color.clear.frame(height: 20)
        }
    }
    
    private func extractDates() -> [DateValue] {
        let calendar = Calendar.current
        
        let currentMonth = calendar.component(.month, from: self.currentMonth)
        let currentYear = calendar.component(.year, from: self.currentMonth)
        
        guard let startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1)) else {
            return []
        }
        
        var days = startDate.getAllDatesInMonth().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: startDate)
        for _ in 0..<(firstWeekday - 1) {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func filteredReminders() -> [ReminderModel] {
        reminderManager.reminders.filter { reminder in
            if reminder.interval == .selectDate {
                return Calendar.current.isDate(reminder.createdAt, inSameDayAs: selectedDate)
            }
            return false
        }
    }
    
    private func hasReminderOnDate(date: Date) -> Bool {
        reminderManager.reminders.contains { reminder in
            if reminder.interval == .selectDate {
                return Calendar.current.isDate(reminder.createdAt, inSameDayAs: date)
            }
            return false
        }
    }
    
    private func getRandomColorForDate(date: Date) -> Color {
        let dateString = "\(Calendar.current.component(.year, from: date))\(Calendar.current.component(.month, from: date))\(Calendar.current.component(.day, from: date))"
        let hash = abs(dateString.hashValue)
        return taskColors[hash % taskColors.count]
    }
    
    private func isReminderTemporarilyCompleted(_ reminder: ReminderModel) -> Bool {
        reminder.completed || temporaryCompletedIds.contains(reminder.id)
    }
    
    private func toggleTemporaryCompletion(reminder: ReminderModel) {
        if reminder.completed {
            return
        }
        
        if temporaryCompletedIds.contains(reminder.id) {
            temporaryCompletedIds.remove(reminder.id)
        } else {
            temporaryCompletedIds.insert(reminder.id)
        }
    }
    
    private func resetTemporaryCompletedIds() {
        temporaryCompletedIds.removeAll()
    }
    
    private func saveCompletedReminders() {
        for reminder in filteredReminders() {
            if temporaryCompletedIds.contains(reminder.id) {
                var updatedReminder = reminder
                updatedReminder.completed = true
                reminderManager.updateReminder(updatedReminder)
            }
        }
        resetTemporaryCompletedIds()
    }
    
    private func areAllRemindersActuallyCompleted() -> Bool {
        let reminders = filteredReminders()
        guard !reminders.isEmpty else { return false }
        
        return reminders.allSatisfy { reminder in
            reminder.completed
        }
    }
}

struct DateValue: Identifiable {
    var id = UUID()
    var day: Int
    var date: Date
}

extension Date {
    func getAllDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        
        guard let range = calendar.range(of: .day, in: .month, for: self),
              let firstDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDate)
        }
    }
}

struct AppConstants {
    static let metricsBaseURL = "https://ckencount.com/app/metrics"
    static let salt = "61M06DohLclYeAFtvLFObvgKViYH4pQg"
    static let oneSignalAppID = "774bf801-cc39-4287-8033-caab71655bdd"
    static let userDefaultsKey = "count"
    static let remoteConfigStateKey = "countState"
    static let remoteConfigKey = "chick"
}

struct MetricsResponse {
    let isOrganic: Bool
    let url: String
    let parameters: [String: String]
}

#Preview {
    CareCalendar()
        .environmentObject(ReminderManager())
}

