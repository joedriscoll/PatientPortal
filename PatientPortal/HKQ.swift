//
//  HKQ.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 2/5/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
import HealthKit

class HKQ {
    let health:HKHealthStore = HKHealthStore()
    let stepQuantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierStepCount)
    
    func backgroundHealth(){
        health.enableBackgroundDeliveryForType(stepQuantityType, frequency: HKUpdateFrequency.Hourly, withCompletion: {(success: Bool, error: NSError!) in
            if success{
                println("Enabled background delivery of step changes")
            } else {
                if let theError = error{
                    print("Failed to enable background delivery of weight changes. ")
                    println("Error = \(theError)")
                }
            }
            
        })
    }
    
    func datesFromToday() -> (NSDate, NSDate)
    {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let nowDate: NSDate = NSDate()
        
        let endDate: NSDate = nowDate
        let starDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: -1, toDate: endDate, options: NSCalendarOptions.allZeros)!
        
        return (starDate, endDate)
    }

    
    func query(){
        let (starDate: NSDate, endDate: NSDate) = self.datesFromToday()
        
        let predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(starDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        
        let query: HKStatisticsQuery = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: HKStatisticsOptions.CumulativeSum) {
            (_query, result, error) -> Void in
            
            println(result)
            println(_query)
            println(result.sumQuantity())
            println("hihihi")
            
        }
        health.executeQuery(query)
    }
        
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = NSSet(array:[])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        health.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }

}
