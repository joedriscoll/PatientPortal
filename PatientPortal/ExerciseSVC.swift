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
    
    
    var cell:UITableViewCell?
    var eQuest:ExerciseRequest?
    var eAlert:ExerciseAlert?
        override func viewDidLoad() {
        super.viewDidLoad()
        eAlert = ExerciseAlert()
        eAlert?.setUp(CGRectMake(20,20,300,300), name:"hi",setReps:"There it is")
        self.eQuest = ExerciseRequest(tableView: exerciseTable)
        //self.eQuest?.update()
        //self.eQuest?.getExercises()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(exerciseTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (eQuest != nil){
            return eQuest!.items.count;
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
        cell!.textLabel?.text = eQuest!.items[indexPath.row]
        return cell!
    }
    
    func tableView(exerciseTable: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if eAlert?.superview != background{
            eAlert?.update(eQuest!.items[indexPath.row],setReps:eQuest!.repD[indexPath.row],exercise_id:eQuest!.eid[indexPath.row])
            background.addSubview(eAlert!)
            
            
        }
        
        println("Hi")// direct to patient page
    }
    
    
    
    
    @IBAction func homeTapped(sender: UIButton) {
        if eAlert?.superview != self{
            self.dismissViewControllerAnimated(true, completion:nil)
        }
    }

    class ExerciseRequest{
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var get:NSString
        var url:NSURL
        var eid: [Int]
        var items:[String]
        var repD:[String]
        var request:NSMutableURLRequest
        var jsonData:NSDictionary?
        //weak var tableView:UITableView?
        var queue:NSOperationQueue?

        init(tableView:UITableView){
            println("initialized request")
            self.get = "?session_key=\(self.session_key)"
            self.url = NSURL(string: "http://localhost:8000/ptapi/getExercises"+get)!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "GET"
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
            self.items = ["hi"]
            self.repD = ["3 sets x 15 reps"]
            self.eid = [1]
            //self.tableView = tableView
            self.queue  = NSOperationQueue()
        }
    
        func update(){
            self.session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
            self.get = "?session_key=\(self.session_key)"
            self.url = NSURL(string: "http://localhost:8000/ptapi/getPatients"+get)!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "GET"
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        func getExercises() -> Void {
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            self.items = []
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if (error != nil) {
                    println("API error: \(error), \(error.userInfo)")
                }
                var jsonError:NSError?
                self.jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                if (jsonError != nil) {
                    println("Error parsing json: \(jsonError)")
                }
                if (self.jsonData?.valueForKey("success") as Int == 0){
                    let appDomain = NSBundle.mainBundle().bundleIdentifier
                    NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
                }
               // self.tableView?.reloadData()
            })
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
