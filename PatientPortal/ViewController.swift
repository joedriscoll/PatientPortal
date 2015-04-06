//
//  ViewController.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/5/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    var hk: HKQ?
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var painAlert: PainLevel?

    @IBOutlet var background: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn == 1) {
            setUpHealth()
            
            }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else{
            setUpHealth()
            self.painAlert = PainLevel()
            self.painAlert?.setUp(CGRectMake(self.background.frame.width * 0.025,100,self.background.frame.width * 0.95,265))
            let username = prefs.valueForKey("USERNAME") as NSString
            titleBar.title = username+"'s Patient Portal"
            //self.usernameLabel.text = prefs.valueForKey("USERNAME") as NSString
        }
    }
    
    
    func setUpHealth() {
        if prefs.integerForKey("IsHealthQuery") as Int != 1{
            self.hk = HKQ()
            self.hk?.authorizeHealthKit { (authorized,  error) -> Void in
                if authorized {
                    println("HealthKit authorization received.")
                    self.hk?.backgroundHealth()
                    //self.hk?.query()
                    self.hk?.queryColl()
                    self.prefs.setInteger(1, forKey: "IsHealthQuery")
                }
                else
                {
                    println("HealthKit authorization denied!")
                    if error != nil {
                        println("\(error)")
                    }
                
                }
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func reloadSteps(sender: UIButton) {
        self.hk?.stopQueryCol()
        self.prefs.setInteger(0, forKey: "IsHealthQuery")
        setUpHealth()
    }
    @IBAction func logPainTapped(sender: UIButton) {
        self.painAlert?.clear()
        self.background.addSubview(self.painAlert!)
    }

    @IBAction func logoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        self.hk?.stopQueryCol()
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    
}

