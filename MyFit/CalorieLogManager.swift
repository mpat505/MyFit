import CoreData
import SwiftUI

class CalorieLogManager: ObservableObject {
    @Published var calorieLogs: [CalorieLog] = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchLogs()
    }

    // Fetch all logs from Core Data
    func fetchLogs() {
        let request: NSFetchRequest<CalorieLog> = CalorieLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CalorieLog.date, ascending: false)]
        
        do {
            calorieLogs = try context.fetch(request)
        } catch {
            print("Failed to fetch logs: \(error.localizedDescription)")
        }
    }

    // Add a new log to Core Data
    func addLog(date: Date, calories: Int, protein: Int) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "CalorieLog", in: context) else {
            print("Failed to create entity description.")
            return
        }
        let newLog = CalorieLog(entity: entityDescription, insertInto: context)
        newLog.date = date
        newLog.calories = Int64(calories)
        newLog.protein = Int64(protein)

        saveContext()
        fetchLogs() // Refresh logs
    }


    // Delete a log from Core Data
    func deleteLog(_ log: CalorieLog) {
        context.delete(log)
        saveContext()
        fetchLogs() // Refresh logs after deletion
    }

    // Save the context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
            context.rollback() // Rollback in case of failure
        }
    }
}

