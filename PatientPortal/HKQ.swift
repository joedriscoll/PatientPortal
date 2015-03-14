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
    var c = Connect()
    var hkcollquery:HKQuery?
    let health:HKHealthStore = HKHealthStore()
    let stepQuantityType = HKQuantityType.quantityTypeForIdentifier(
        HKQuantityTypeIdentifierStepCount)
    var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
    
    func backgroundHealth(){
        health.enableBackgroundDeliveryForType(stepQuantityType, frequency: HKUpdateFrequency.Immediate, withCompletion: {(success: Bool, error: NSError!) in
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
    
    
    init(){
        println("startedhkq")
        
    }
    
    func datesFromToday() -> (NSDate, NSDate)
    {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        var nowDate: NSDate = NSDate()
        var components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit , fromDate: nowDate)
        components.minute = 0
        var endDate = calendar.dateFromComponents(components)!
        var starDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: -24*3, toDate: endDate, options: NSCalendarOptions.allZeros)!
        var realEndDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitYear, value: 5, toDate: endDate, options: NSCalendarOptions.allZeros)!
        return (starDate, realEndDate)
    }

    func queryColl(){
        var format = NSDateFormatter()
        format.dateFormat  = "yyyy-MM-dd"
        var hourformat = NSDateFormatter()
        hourformat.dateFormat = "HH"
        var hPost = PostReq(post: "steps=None&session_key=None", url: c.ip+"/ptapi/addsteps")
        var proc = Processor()
        var (starDate: NSDate, endDate: NSDate) = self.datesFromToday()
        var predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(starDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        var hour = NSDateComponents()
        hour.hour = 1
        var query:HKStatisticsCollectionQuery = HKStatisticsCollectionQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: HKStatisticsOptions.CumulativeSum, anchorDate: endDate, intervalComponents: hour)
        query.initialResultsHandler = {
            query, results, error in
            if error != nil {
                // Perform proper error handling here
                println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
                abort()
            }
            var endDate = NSDate()
            let calendar = NSCalendar.currentCalendar()
            var dateValue = ""
            let startDate =
            calendar.dateByAddingUnit(.DayCalendarUnit,value: -5, toDate: endDate, options: nil)
            results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
                statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValueForUnit(HKUnit.countUnit())
                    dateValue = dateValue + format.stringFromDate(date) + ","
                    dateValue = dateValue + String(Int(value)) + ","
                    dateValue = dateValue + hourformat.stringFromDate(date) + "^"
                    //dateValue.append(datadic)
                }
            }
            
            println(dateValue)
            hPost.update("steps=\(dateValue)&session_key=\(self.session_key)", url: self.c.ip+"/ptapi/addsteps")
            hPost.Post(proc)
        }
        
        query.statisticsUpdateHandler = {
            query, stats, results, error in
            if error != nil {
                // Perform proper error handling here
                println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
                abort()
            }
            println("this is updateing")
            var endDate = NSDate()
            let calendar = NSCalendar.currentCalendar()
            var dateValue = ""
            let startDate =
            calendar.dateByAddingUnit(.HourCalendarUnit,value: -3, toDate: endDate, options: nil)
            results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
                statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValueForUnit(HKUnit.countUnit())
                    dateValue = dateValue + format.stringFromDate(date) + ","
                    dateValue = dateValue + String(Int(value)) + ","
                    dateValue = dateValue + hourformat.stringFromDate(date) + "^"
                    //dateValue.append(datadic)
                }
            }
            println("updated")
            println(dateValue)
            hPost.update("steps=\(dateValue)&session_key=\(self.session_key)", url: self.c.ip+"/ptapi/addsteps")
            hPost.Post(proc)
            
        }
        self.hkcollquery = query
        health.executeQuery(self.hkcollquery!)
    }
    
    
    func stopQueryCol(){
        health.stopQuery(self.hkcollquery!)
        
    }
    
    func query(){
        var (starDate: NSDate, endDate: NSDate) = self.datesFromToday()
        println("running quu")
        println(starDate)
        println(endDate)
        var predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(starDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        println(predicate)
        var query: HKStatisticsQuery = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: HKStatisticsOptions.CumulativeSum) {
            (_query, result, error) -> Void in
            println(error)
            println(result)
            println(_query)
            println(result.sumQuantity())
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
            let error = NSError(domain: "kkkk", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
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
