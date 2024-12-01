import SwiftUI

struct CalorieTrackingView: View {
    @ObservedObject var logData: CalorieLogManager  // Core Data-backed data model
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            Text("Calorie & Protein Tracker")
                .font(.largeTitle)
                .padding()
            
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .padding()
            
            HStack {
                VStack {
                    TextField("Enter calories", text: $calories)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                    TextField("Enter protein (g)", text: $protein)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                }
                
                Button(action: addCalorieLog) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(.blue)
                }
            }
            
            List {
                ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(formattedDate(date))) {
                        ForEach(groupedLogs[date]!) { log in
                            VStack(alignment: .leading) {
                                Text("Calories: \(log.calories) kcal")
                                Text("Protein: \(log.protein) g")
                            }
                        }
                        .onDelete { indices in
                            indices.forEach { index in
                                let log = groupedLogs[date]![index]
                                deleteLog(log)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Group logs by date
    private var groupedLogs: [Date: [CalorieLog]] {
        Dictionary(grouping: logData.calorieLogs) { log in
            Calendar.current.startOfDay(for: log.date ?? Date())
        }
    }
    
    // Save a new log entry to Core Data
    private func addCalorieLog() {
        guard let calorieCount = Int(calories), calorieCount > 0,
              let proteinCount = Int(protein), proteinCount > 0 else { return }
        
        // Add a new log to Core Data through the `logData` model
        logData.addLog(date: selectedDate, calories: calorieCount, protein: proteinCount)
        
        // Clear input fields
        calories = ""
        protein = ""
    }
    
    // Delete a log entry from Core Data
    private func deleteLog(_ log: CalorieLog) {
        logData.deleteLog(log)
    }
    
    // Helper function to format dates
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CalorieTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieTrackingView(logData: CalorieLogManager(context: PersistenceController.shared.container.viewContext))
    }
}


