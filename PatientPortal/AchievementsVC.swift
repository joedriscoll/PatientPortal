//
//  AchievementsVC.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 2/4/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit

class AchievementsVC: UIViewController {

    @IBOutlet var background: UIView!
    @IBOutlet weak var aTable: UITableView!
    var aQuest:GetReq?
    var aProc:AchProc?
    var c = Connect()
    var cell:UITableViewCell?
    var aAlert:AchieveAlert?


    override func viewDidLoad() {
        super.viewDidLoad()
        aProc = AchProc(table: aTable)
        aQuest = GetReq(post: "?session_key=None", url: c.ip+"/ptapi/getAchievements")
        var rec = CGRectMake((self.background.frame.width - 305)/2.0,150,305,130)
        aAlert = AchieveAlert()
        var name = "name"
        var des = "des"
        aAlert?.setUp(rec, name: name, des: des, aP: aProc!)



        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        self.aQuest?.update("?session_key=\(session_key)", url: c.ip+"/ptapi/getAchievements")
        self.aQuest?.Get(self.aProc!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(aTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (aProc != nil){
            return aProc!.items.count;
        }
        else{
            return 0
        }
    }
    
    func tableView(aTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        self.cell = self.aTable!.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        if (cell == nil) {
            println("itwasnil")
            self.cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = aProc!.items[indexPath.row]
        return cell!
    }
    
    func tableView(aTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if aAlert?.superview != background{
            var name = aProc!.items[indexPath.row]
            aAlert?.update(name, des:aProc!.nameToD!.valueForKey(name) as String)
            background.addSubview(aAlert!)
        }
    }

    

    @IBAction func homeTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion:nil)
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
