import SwiftUI

struct DashboardView: View {
    @ObservedObject var logData: CalorieLogManager
    @State private var streakCount: Int = 0
    @State private var totalCaloriesBurned: Double = 0
    @State private var totalSteps: Double = 0

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .padding()

                LazyVGrid(columns: columns, spacing: 20) {
                    // Streak Count Box
                    InfoBoxView(title: "🔥 Streak") {
                        Text("\(streakCount) Days")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    // Weekly Summary Boxes
                    InfoBoxView(title: "Weekly Calories Burned") {
                        Text("\(Int(totalCaloriesBurned)) kcal")
                            .font(.title)
                    }
                    InfoBoxView(title: "Weekly Steps") {
                        Text("\(Int(totalSteps)) steps")
                            .font(.title)
                    }

                    // Latest Log Information Boxes
                    // Inside the LazyVGrid for "Latest Log Information Boxes"
                    if let latestLog = logData.calorieLogs.last {
                        InfoBoxView(title: "Latest Log Date") {
                            Text(formattedDate(latestLog.date ?? Date())) // Provide a default date if latestLog.date is nil
                                .font(.title)
                        }
                        InfoBoxView(title: "Latest Calories") {
                            Text("\(latestLog.calories) kcal")
                                .font(.title)
                        }
                        InfoBoxView(title: "Latest Protein") {
                            Text("\(latestLog.protein) g")
                                .font(.title)
                        }
                    } else {
                        InfoBoxView(title: "Latest Log Date") {
                            Text("N/A")
                                .font(.title)
                        }
                        InfoBoxView(title: "Latest Calories") {
                            Text("N/A")
                                .font(.title)
                        }
                        InfoBoxView(title: "Latest Protein") {
                            Text("N/A")
                                .font(.title)
                        }
                    }

                }
                .padding()

                // Full-width Calendar Box placed outside the grid
                InfoBoxView(title: "Monthly Log Calendar") {
                    CalendarBoxView(logData: logData)
                }
                .padding([.leading, .trailing, .bottom], 20) // Adds padding for full-width appearance
            }
            .onAppear {
                calculateStreak()
                fetchHealthKitData()
            }
        }
    }

    // Helper functions for streak, summaries, etc.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var previousDate: Date?

        for log in logData.calorieLogs.sorted(by: { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }) {
            if let logDate = log.date,
               let prevDate = previousDate,
               let previousDay = calendar.date(byAdding: .day, value: -1, to: prevDate),
               calendar.isDate(logDate, inSameDayAs: previousDay) {
                streak += 1
            } else if previousDate == nil, let logDate = log.date {
                streak = 1
                previousDate = logDate
            } else {
                break
            }
            previousDate = log.date
        }

        streakCount = streak
    }

    private func fetchHealthKitData() {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endDate = Date()

        // Fetch calories burned
        HealthKitManager.shared.fetchCaloriesBurned(startDate: startDate, endDate: endDate) { calories, error in
            if let calories = calories {
                DispatchQueue.main.async {
                    self.totalCaloriesBurned = calories
                }
            }
        }

        // Fetch step data
        HealthKitManager.shared.fetchSteps(startDate: startDate, endDate: endDate) { steps, error in
            if let steps = steps {
                DispatchQueue.main.async {
                    self.totalSteps = steps
                }
            }
        }
    }
}

// Reusable component for each box in the grid
struct InfoBoxView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}



struct CalendarBoxView: View {
    @ObservedObject var logData: CalorieLogManager
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7) // 7 columns for days of the week

    var body: some View {
        VStack {
            // Month Title
            Text(currentMonthYear)
                .font(.headline)
                .padding(.bottom, 5)
            
            LazyVGrid(columns: columns, spacing: 5) { // Reduced spacing for better fit
                // Weekday Headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 20) // Explicit frame for consistency
                }
                
                // Offset for the first day of the month
                ForEach(0..<firstDayOfMonthOffset(), id: \.self) { _ in
                    Text("") // Empty Text for offset
                        .frame(width: 30, height: 30)
                }
                
                // Days of the Month
                ForEach(daysInMonth(), id: \.self) { date in
                    Text("\(Calendar.current.component(.day, from: date))")
                        .frame(width: 30, height: 30)
                        .background(isLoggedDay(date: date) ? AnyView(Circle().fill(Color.blue)) : AnyView(Circle().stroke(Color.gray)))
                        .foregroundColor(isLoggedDay(date: date) ? .white : .primary)
                }
            }
            .padding(.horizontal, 5) 
        }
    }

    // Helper function to get the current month and year
    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    // Helper function to get all days in the current month
    private func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        let components = calendar.dateComponents([.year, .month], from: Date())
        
        return range.compactMap { day -> Date? in
            var dateComponents = components
            dateComponents.day = day
            return calendar.date(from: dateComponents)
        }
    }

    // Helper function to check if a specific date has a log entry
    private func isLoggedDay(date: Date) -> Bool {
        logData.calorieLogs.contains {
            if let logDate = $0.date {
                return Calendar.current.isDate(logDate, inSameDayAs: date)
            }
            return false
        }
    }

    // Helper function to calculate offset for the first day of the month
    private func firstDayOfMonthOffset() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let firstDayOfMonth = calendar.date(from: components) ?? Date()
        return calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0 for Sunday, 1 for Monday, etc.
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Use the shared persistence controller's context
        let logData = CalorieLogManager(context: PersistenceController.shared.container.viewContext)
        
        // Preview the DashboardView with the existing setup
        DashboardView(logData: logData)
    }
}
