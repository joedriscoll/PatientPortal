//
//  ViewController.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/5/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    var hk = HKQ()
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var painAlert: PainLevel?

    @IBOutlet var background: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hk.authorizeHealthKit { (authorized,  error) -> Void in
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
        self.hk.backgroundHealth()
        self.hk.query()
    
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else{
            self.painAlert = PainLevel()
            self.painAlert?.setUp(CGRectMake(20,100,300,230))
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
    
    
}

