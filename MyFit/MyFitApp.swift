import SwiftUI
import CoreData

@main
struct MyFitApp: App {
    // Initialize the shared data model instance
    @StateObject private var logData = CalorieLogManager(context: PersistenceController.shared.container.viewContext)
    @State private var selectedTab: Tab = .dashboard

    enum Tab {
        case calorieTracker
        case dashboard
        case analytics
    }

    var body: some Scene {
        WindowGroup {
            VStack {
                // Main content area for switching views based on selectedTab
                Group {
                    switch selectedTab {
                    case .calorieTracker:
                        CalorieTrackingView(logData: logData) // Pass logData to CalorieTrackingView
                    case .dashboard:
                        DashboardView(logData: logData) // Pass logData to DashboardView
                    case .analytics:
                        AnalyticsView(logData: logData) // Pass logData to AnalyticsView
                    }
                }

                // Bottom navigation bar with buttons to switch views
                HStack {
                    Button(action: { selectedTab = .calorieTracker }) {
                        VStack {
                            Image(systemName: "flame.fill")
                            Text("Calories")
                        }
                    }
                    .foregroundColor(selectedTab == .calorieTracker ? .blue : .gray)

                    Spacer()

                    Button(action: { selectedTab = .dashboard }) {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Dashboard")
                        }
                    }
                    .foregroundColor(selectedTab == .dashboard ? .blue : .gray)

                    Spacer()

                    Button(action: { selectedTab = .analytics }) {
                        VStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Analytics")
                        }
                    }
                    .foregroundColor(selectedTab == .analytics ? .blue : .gray)
                }
                .frame(height: 60)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

