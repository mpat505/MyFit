import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager() 
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Request Permissions
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)! // Step count type
        
        healthStore.requestAuthorization(toShare: [], read: [calorieType, stepType]) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Fetch Calories Burned
    func fetchCaloriesBurned(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(caloriesBurned, nil)
        }
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Steps
    func fetchSteps(startDate: Date, endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            
            let stepCount = sum.doubleValue(for: HKUnit.count())
            completion(stepCount, nil)
        }
        healthStore.execute(query)
    }
}
