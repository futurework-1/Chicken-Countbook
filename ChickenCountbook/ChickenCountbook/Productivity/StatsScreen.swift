import SwiftUI

struct StatsScreen: View {
    enum PeriodType: String, CaseIterable, Identifiable { case weeks = "Weeks", months = "Months"; var id: String { rawValue } }
    enum Category: String, CaseIterable, Identifiable { case all = "All", sold = "Sold", used = "Used", gifted = "Gifted"; var id: String { rawValue } }
    
    @EnvironmentObject var manager: EggEntryManager
    @Environment(\.dismiss) private var dismiss
    @State private var period: PeriodType = .weeks
    @State private var selectedCategory: Category = .all
    @State private var currentWeek: Int = 12
    @State private var currentMonth: Date = Date()
    @State private var barValues: [Int] = StatsScreen.randomData(count: 7)
    @State private var selectedLabelIndex: Int? = nil
    @State private var noteText: String = ""
    @State private var chickenRandoms: [String: Int] = [:]
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 60 : 100)
                    .overlay(
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                            
                            Text("Egg Statistics")
                                .font(.system(size: 17, weight: .medium))
                                .padding(.top)
                            
                            Image(systemName: "chevron.left")
                                .foregroundColor(.clear)
                                .font(.system(size: 22, weight: .medium))
                            Spacer()
                        }.padding(.bottom)
                        , alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
                VStack(spacing: 10) {
                    CustomSegmentedControl(
                        items: PeriodType.allCases,
                        selection: Binding(get: { period }, set: { setPeriod($0) })
                    )
                    .frame(height: 40)
                    .padding(.horizontal)
                    CustomSegmentedControl(
                        items: Category.allCases,
                        selection: Binding(get: { selectedCategory }, set: { setCategory($0) })
                    )
                    .frame(height: 40)
                    .padding(.horizontal)
                    
                    if !manager.entries.isEmpty {
                        ScrollView {
                            HStack {
                                Text(period == .weeks ? "Week \(currentWeek)" : monthYearString(for: currentMonth))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { prevPeriod() }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 22, weight: .bold))
                                }
                                Button(action: { nextPeriod() }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 22, weight: .bold))
                                }
                                .padding(.leading)
                            }
                            .padding()
                            Image(period == .weeks ? .chartBack : .chartBackM)
                                .resizable()
                                .frame(width: 350, height: 390)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        VStack {
                                            HStack(alignment: .bottom, spacing: period == .weeks ? 16 : 25) {
                                                ForEach(0..<(period == .weeks ? 7 : 5), id: \ .self) { idx in
                                                    let value = barValues[safe: idx] ?? 10
                                                    BarView(value: value, maxValue: 60)
                                                        .frame(width: 24)
                                                }
                                            }
                                            .frame(height: 220)
                                            .padding(.horizontal, 30)
                                            HStack(spacing: period == .weeks ? 5 : 16) {
                                                ForEach(0..<(period == .weeks ? 7 : 5), id: \ .self) { idx in
                                                    Button(action: {
                                                        selectedLabelIndex = idx
                                                        updateChickenRandoms()
                                                    }) {
                                                        Text(period == .weeks ? weekDays[idx] : weekLabels[idx])
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(selectedLabelIndex == idx ? .white : .blue)
                                                            .frame(width: 38, height: 32)
                                                            .background(selectedLabelIndex == idx ? Color.blue : Color.white)
                                                            .clipShape(Capsule())
                                                            .overlay(
                                                                Capsule().stroke(Color.blue, lineWidth: 2)
                                                            )
                                                    }
                                                }
                                            }
                                            .padding(.top, 20)
                                            .padding(.horizontal, 30)
                                        }
                                   
                                    }
                                    .offset(y: -22)
                                    .offset(x: period == .weeks ? 15 : 6)
                                )
                            
                            if let selected = selectedLabelIndex {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Chicken Name")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.leading, 8)
                                    VStack(spacing: 0) {
                                        ForEach(Array(manager.entries.compactMap { $0.chickenName }.uniqued().enumerated()), id: \.element) { idx, name in
                                            HStack {
                                                Text(name)
                                                    .font(.system(size: 16, weight: .regular))
                                                    .foregroundColor(.black)
                                                Spacer()
                                                Text("\(chickenRandoms[name] ?? 1)")
                                                    .font(.system(size: 16, weight: .regular))
                                                    .foregroundColor(.blue)
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal)
                                            .background(Color.white)
                                            .cornerRadius(0)
                                            if idx < manager.entries.compactMap { $0.chickenName }.uniqued().count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(20)
                                    Text("Note")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                        .padding(.leading, 8)
                                    TextField("Enter here", text: $noteText)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .padding(.bottom, 8)
                                    Button(action: {
                                        if !noteText.trimmingCharacters(in: .whitespaces).isEmpty {
                                            manager.addNote(noteText)
                                            noteText = ""
                                        }
                                    }) {
                                        Text("Save")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(14)
                                    }
                                    .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
                                    .opacity(noteText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                                    .padding(.top, 8)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            }
                        }
                        .padding(.bottom, 30)
                    } else {
                        Spacer()
                        Text("No data yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        Spacer()
                    }
                }.padding(.top, 50)
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Actions
    private func setPeriod(_ newPeriod: PeriodType) {
        if period != newPeriod {
            period = newPeriod
            barValues = StatsScreen.randomData(count: newPeriod == .weeks ? 7 : 5)
            updateChickenRandoms()
        }
    }
    private func setCategory(_ newCategory: Category) {
        selectedCategory = newCategory
        barValues = StatsScreen.randomData(count: period == .weeks ? 7 : 5)
        updateChickenRandoms()
    }
    private func prevPeriod() {
        if period == .weeks {
            currentWeek = max(1, currentWeek - 1)
            barValues = StatsScreen.randomData(count: 7)
        } else {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            barValues = StatsScreen.randomData(count: 5)
        }
    }
    private func nextPeriod() {
        if period == .weeks {
            currentWeek += 1
            barValues = StatsScreen.randomData(count: 7)
        } else {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            barValues = StatsScreen.randomData(count: 5)
        }
    }
    
    // MARK: - Helpers
    private var weekDays: [String] { ["M", "T", "W", "T", "F", "S", "S"] }
    private var weekLabels: [String] { ["W1", "W2", "W3", "W4", "W5"] }
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    static func randomData(count: Int) -> [Int] {
        (0..<count).map { _ in Int.random(in: 10...60) }
    }
    private func updateChickenRandoms() {
        let names = manager.entries.compactMap { $0.chickenName }.uniqued()
        var newRandoms: [String: Int] = [:]
        for name in names {
            newRandoms[name] = Int.random(in: 1...12)
        }
        chickenRandoms = newRandoms
    }
}

struct BarView: View {
    let value: Int
    let maxValue: Int
    var body: some View {
        GeometryReader { geo in
            let height = CGFloat(value) / CGFloat(maxValue) * geo.size.height
            TopRoundedRectangle(radius: 20)
                .fill(Color.bar)
                .frame(height: height)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct CustomSegmentedControl<T: Hashable & Identifiable & RawRepresentable>: View where T.RawValue == String {
    let items: [T]
    @Binding var selection: T
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \ .element.id) { idx, item in
                Button(action: { selection = item }) {
                    Text(item.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selection == item ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selection == item ? Color.blue : Color.white)
                        .cornerRadius(10)
                        .padding(selection == item ? 2 : 0)
                }
                if items.count > 2 && idx < items.count - 1 {
                    Divider()
                        .frame(width: 1, height: 22)
                        .background(Color(white: 0.85))
                        .padding(.vertical, 8)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    StatsScreen().environmentObject(EggEntryManager())
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
