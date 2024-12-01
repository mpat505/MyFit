import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var logData: CalorieLogManager
    @State private var selectedTimeRange: TimeRange = .month // Default to month view
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Analytics")
                    .font(.largeTitle)
                    .padding()

                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Calorie Intake Chart
                VStack {
                    Text("Calorie Intake Over Time")
                        .font(.title2)
                        .padding(.top)
                    Chart(dailyCalorieData(for: selectedTimeRange)) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Calories", dataPoint.calories)
                        )
                        .foregroundStyle(Color.blue)
                    }
                    .frame(height: 300)
                    .padding()
                }

                // Protein Intake Chart
                VStack {
                    Text("Protein Intake Over Time")
                        .font(.title2)
                        .padding(.top)
                    Chart(dailyProteinData(for: selectedTimeRange)) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Protein", dataPoint.protein)
                        )
                        .foregroundStyle(Color.purple)
                    }
                    .frame(height: 300)
                    .padding()
                }
            }
        }
    }

    // MARK: - Data Preparation Functions

    private func dailyCalorieData(for range: TimeRange) -> [CalorieDataPoint] {
        let calendar = Calendar.current
        let startDate: Date
        switch range {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }

        let filteredLogs = logData.calorieLogs.filter { ($0.date ?? Date()) >= startDate }
        let groupedLogs = Dictionary(grouping: filteredLogs, by: { calendar.startOfDay(for: $0.date ?? Date()) })

        return groupedLogs.map { (date, logs) in
            let totalCalories = logs.reduce(0) { $0 + Int($1.calories) }
            return CalorieDataPoint(date: date, calories: totalCalories)
        }
        .sorted { $0.date < $1.date }
    }

    private func dailyProteinData(for range: TimeRange) -> [ProteinDataPoint] {
        let calendar = Calendar.current
        let startDate: Date
        switch range {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        }

        let filteredLogs = logData.calorieLogs.filter { ($0.date ?? Date()) >= startDate }
        let groupedLogs = Dictionary(grouping: filteredLogs, by: { calendar.startOfDay(for: $0.date ?? Date()) })

        return groupedLogs.map { (date, logs) in
            let totalProtein = logs.reduce(0) { $0 + Int($1.protein) }
            return ProteinDataPoint(date: date, protein: totalProtein)
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - Data Structures

struct CalorieDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
}

struct ProteinDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let protein: Int
}

// MARK: - Enum for Time Ranges
enum TimeRange: String, CaseIterable {
    case week = "Past Week"
    case month = "Past Month"
    case threeMonths = "Past 3 Months"
}

// MARK: - Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(logData: CalorieLogManager(context: PersistenceController.shared.container.viewContext))
    }
}

