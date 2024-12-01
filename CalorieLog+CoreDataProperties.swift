
import Foundation
import CoreData

extension MyFit.CalorieLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyFit.CalorieLog> {
        return NSFetchRequest<MyFit.CalorieLog>(entityName: "CalorieLog")
    }

    @NSManaged public var calories: Int64
    @NSManaged public var date: Date?
    @NSManaged public var protein: Int64
}

extension MyFit.CalorieLog: Identifiable {}
