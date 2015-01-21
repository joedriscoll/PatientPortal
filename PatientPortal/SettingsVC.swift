//
//  SettingsVC.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/8/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    var setReq:GetReq?
    var set:setProc?
    
    @IBOutlet var changePTButton: UIButton!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet var assingedPTLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSettings()
        setReq = GetReq(post: "?session_key=None&username=None", url: "http://localhost:8000/ptapi/settings")
        set = setProc(but:changePTButton, lab:assingedPTLabel)

    }
    
    deinit{
        
        println("deleted")
    }
    class setProc:Processor{
        var but:UIButton
        var lab:UILabel
        init(but:UIButton, lab:UILabel){
            self.but = but
            self.lab = lab
        }
        deinit{
            println("deleted setting processes")
        }
        override func processData(data: NSDictionary) {
            super.processData(data)
            let ptUsername:NSString = data.valueForKey("assigned_pt") as NSString!
            dispatch_async(dispatch_get_main_queue()) {
                self.lab.text = ptUsername
            
                if (ptUsername == "None"){
                
                    self.but.setTitle("Assign a Physical Therapist", forState: UIControlState.Normal)
                }
                else {
                    self.but.setTitle("Change Assigned Physical Therapist", forState: UIControlState.Normal)
                }
            }
        }
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
        setReq?.update("?session_key=\(session_key)&username=\(username)", url: "http://localhost:8000/ptapi/settings")
        setReq?.Get(set!)
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
