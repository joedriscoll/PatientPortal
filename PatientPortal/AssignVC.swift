//
//  AsignPTVC.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/8/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit

class AssignVC: UIViewController {
    
    @IBOutlet weak var ptUsername: UITextField!
    var asPost:PostReq?
    var aP:asProcessor?
    var c:Connect = Connect()
    override func viewDidLoad() {
        super.viewDidLoad()
        asPost = PostReq(post: "pt_username=None&session_key=None", url: (self.c.ip as String) + "/ptapi/assignPT")
        aP = asProcessor(VC: self)
        
        // Do any additional setup after loading the view.
    }
    
    deinit{
        println("deleteassignVC")
    }
    
    @IBAction func cancelTapped(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismiss(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class asProcessor:Processor{
        var alertView = UIAlertView()
        weak var VC:AssignVC?
        init(VC:AssignVC){
            self.VC = VC
            alertView = UIAlertView()
            self.alertView.title = "Error"
            self.alertView.delegate = self.VC!
            self.alertView.addButtonWithTitle("OK")
        }
        
        deinit{
            println("process deleted")
        }
        override func processData(data: NSDictionary) {
            super.processData(data)
            let success:NSInteger = data.valueForKey("success") as! NSInteger
            if(success == 1)
            {
                NSLog("Sign Up SUCCESS");
                self.VC?.dismiss()
            } else {
                if data["error_message"] as? NSString != nil {
                    self.alertView.message = data["error_message"] as! NSString as String
                } else {
                    self.alertView.message = "PT Username Not Found"
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.alertView.show()
                }
            }
        }
        }

    @IBAction func changePtTapped(sender: UIButton) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let session_key = prefs.valueForKey("SESSION_KEY") as! NSString
        var ptusername:NSString = ptUsername.text
        asPost?.update("pt_username=\(ptusername)&session_key=\(session_key)", url: (c.ip as String)+"/ptapi/assignPT")
        asPost?.Post(aP!)
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

