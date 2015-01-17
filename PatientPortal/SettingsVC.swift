//
//  SettingsVC.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/8/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    
    @IBOutlet weak var changePTButton: UIButton!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var assingedPTLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSettings()

        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func HomeTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.getSettings()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSettings(){
        let session_key:NSString = prefs.valueForKey("SESSION_KEY") as NSString
        let username:NSString = prefs.valueForKey("USERNAME") as NSString
        var get:NSString = "?session_key=\(session_key)&username=\(username)"
        
        var url:NSURL = NSURL(string: "http://localhost:8000/ptapi/settings"+get)!
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        println(request)
        request.HTTPMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
            let res = response as NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData);
                
                var error: NSError?
                
                let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
                
                
                let ptUsername:NSString = jsonData.valueForKey("assigned_pt") as NSString
                println(ptUsername)
                assingedPTLabel.text = ptUsername
                if (ptUsername == "None"){
                    
                    changePTButton.setTitle("Assign a Physical Therapist", forState: UIControlState.Normal)
                }
                else {
                    changePTButton.setTitle("Change Assigned Physical Therapist", forState: UIControlState.Normal)
                }
                
                
                
                //[jsonData[@"success"] integerValue];
                
            }
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
