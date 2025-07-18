import SwiftUI

struct ProductivityScreen: View {
    @EnvironmentObject var manager: EggEntryManager
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false
    @State private var quantity: String = ""
    @State private var selectedChicken: String? = nil
    
    let chickenNames = ["Henrietta", "Daisy", "Buttercup", "Goldie", "Peaches", "Poppy"]
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 60 : 100)
                    .overlay(
                        Text("Chicken Eggs & Productivity")
                            .font(.system(size: 17, weight: .medium)).padding(.bottom),
                        alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                if let date = selectedDate {
                                    Text(date, formatter: dateFormatter)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Select date")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(10)
                        }
                        Text("Quantity of Eggs")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                        TextField("Enter here", text: $quantity)
                            .keyboardType(.numberPad)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(0.6))
                            .cornerRadius(10)
                            .onChange(of: quantity) { newValue in
                                quantity = newValue.filter { $0.isNumber }
                            }
                            .multilineTextAlignment(.center)
                        Text("Chicken Name (optional)")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                        VStack(spacing: 0) {
                            ForEach(chickenNames, id: \ .self) { name in
                                Button(action: { selectedChicken = name }) {
                                    HStack {
                                        Text(name)
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.black)
                                        Spacer()
                                        if selectedChicken == name {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(Color.white.opacity(0.9))
                                }
                                .cornerRadius(0)
                                if name != chickenNames.last {
                                    Divider()
                                }
                            }
                        }
         
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(20)
                        
                        Button(action: saveEntry) {
                            Text("Save")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
                        .disabled(selectedDate == nil || quantity.isEmpty)
                        .opacity((selectedDate == nil || quantity.isEmpty) ? 0.6 : 1.0)
                        
                    }
                    NavigationLink {
                        StatsScreen()
                    } label: {
                        HStack {
                            Image(.statNavIcon)
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(5)
                            Text("Egg Statistics")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
              
                
            }
            .padding(.top, 50)
            .padding(.bottom, 90)

            if showDatePicker {
                VStack {
                    Spacer().frame(height: 140)
                    VStack(spacing: 0) {
                        DatePicker("Select date", selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { selectedDate = $0 }
                        ), displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding(.top, 8)
                        Button("Done") {
                            showDatePicker = false
                        }
                        .padding(.bottom, 8)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 16)
                    Spacer()
                }
                .padding(.horizontal)
                .transition(.scale)
            }
            
            
        }
        
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func saveEntry() {
        guard let date = selectedDate, let qty = Int(quantity), qty > 0 else { return }
        let entry = EggEntryModel(date: date, quantity: qty, chickenName: selectedChicken)
        manager.addEntry(entry)
        quantity = ""
        selectedChicken = nil
        selectedDate = nil
    }
}

#Preview {
    ProductivityScreen().environmentObject(EggEntryManager())
}
