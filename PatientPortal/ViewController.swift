//
//  ViewController.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/5/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
import HealthKit
let health:HKHealthStore = HKHealthStore()
let stepQuantityType = HKQuantityType.quantityTypeForIdentifier(
    HKQuantityTypeIdentifierStepCount)

class ViewController: UIViewController {
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var painAlert: PainLevel?


    @IBOutlet var background: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleBar: UINavigationItem!
    override func viewDidLoad() {
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
        
        super.viewDidLoad()
        self.painAlert = PainLevel()
        self.painAlert?.setUp(CGRectMake(20,100,300,230))
        authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            }
            else
            {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else{
            let username = prefs.valueForKey("USERNAME") as NSString
            titleBar.title = username+"'s Patient Portal"
            //self.usernameLabel.text = prefs.valueForKey("USERNAME") as NSString
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func logPainTapped(sender: UIButton) {
        self.painAlert?.clear()
        self.background.addSubview(self.painAlert!)
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
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

