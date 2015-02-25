//
//  ExerciseSVC.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/17/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit

class ExerciseSVC: UIViewController {
    @IBOutlet var background: UIView!
    @IBOutlet var exerciseTable: UITableView!
    
    @IBOutlet weak var dateLabel: UILabel!
    var cell:UITableViewCell?
    var eQuest:GetReq?
    var ePost:PostReq?
    var eAlert:ExerciseAlert?
    var eProc:ExerciseProc?
    var c = Connect()
    override func viewDidLoad() {
        super.viewDidLoad()
        eAlert = ExerciseAlert()
        
        self.eQuest = GetReq(post: "?session_key=None", url:c.ip+"/ptapi/getExercisesForPatient")
        self.ePost = PostReq(post:"?session_key=None&exericse_id=None&exercise_date=None&exercise_completion=None", url: c.ip+"/ptapi/addNewInstance")
        eProc = ExerciseProc(table: exerciseTable, lab:dateLabel)
        eAlert?.setUp(CGRectMake((self.background.frame.width - 305)/2.0,100,305,195), name:"hi",setReps:"There it is", urlString:"url it is", eP:self.eProc!)
        dateLabel.textColor = UIColor.darkGrayColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        println(self.background.frame.width)
        println("sfeesf")
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        self.eQuest?.update("?session_key=\(session_key)&date=\(format.stringFromDate(NSDate()))", url: c.ip+"/ptapi/getExercisesForPatient")
        self.eQuest?.Get(self.eProc!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nextTapped(sender: UIButton) {
        println("nextwastapped")
        self.eProc!.next()
    }
    
    
    @IBAction func prevTapped(sender: UIButton) {
        self.eProc!.prev()
    }
    
    func tableView(exerciseTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (eProc != nil){
            return eProc!.items.count;
        }
        else{
            return 0
        }
    }
    
    func tableView(exerciseTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        self.cell = self.exerciseTable!.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        if (cell == nil) {
            println("itwasnil")
            self.cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        cell!.textLabel?.text = eProc!.items[indexPath.row]
        if eProc?.comp[indexPath.row] == 0{
            cell!.textLabel?.textColor = customColor.red
        }
        if eProc?.comp[indexPath.row] == 1{
            cell!.textLabel?.textColor = UIColor.grayColor()
        }
        if eProc?.comp[indexPath.row] == 2{
            cell!.textLabel?.textColor = customColor.firstBlue
        }
        return cell!
    }
    
    func tableView(exerciseTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if eAlert?.superview != background{
                println("hihihih:")
            eAlert?.update(eProc!.items[indexPath.row],setReps:eProc!.repD[indexPath.row], exercise_id:eProc!.eid[indexPath.row],urlString: eProc!.urlD[indexPath.row])
            background.addSubview(eAlert!)
        }
    }

    @IBAction func homeTapped(sender: UIButton) {
        if eAlert?.superview != self{
            self.dismissViewControllerAnimated(true, completion:nil)
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
