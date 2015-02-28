//
//  CustomModels.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/17/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
import Foundation

var customColor = CustomColors()

class Connect {
    //let ip:NSString = "http://54.200.62.58"
    let ip:NSString = "http://localhost:8000"
}

var c = Connect()
class blueButton:UIButton{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = customColor.firstBlue
        self.layer.cornerRadius = 5
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
}


class redButton:UIButton{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = customColor.red
        self.layer.cornerRadius = 5
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
}
class Button: UIButton {
    
    func setUp(title:NSString,frame:CGRect){
        self.backgroundColor = UIColor.lightGrayColor()
        self.setTitle(title, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(14)
        self.frame = frame
        self.layer.cornerRadius = 5

    }
    
}

class ExerciseLabel: UILabel {
    
    func setUp(text:String,frame:CGRect){
        self.font = UIFont.systemFontOfSize(20)
        self.text = text
        self.frame = frame
        self.textColor = UIColor.blackColor()
        self.textAlignment = .Center
    }
}

class ALabel: UILabel {
    
    func setUp(text:String,frame:CGRect){
        self.font = UIFont.systemFontOfSize(16)
        self.text = text
        self.frame = frame
        self.textColor = UIColor.blackColor()
        self.textAlignment = .Center
    }
}

class PainLabel: UILabel {
    
    func setUp(text:String,frame:CGRect){
        self.font = UIFont.systemFontOfSize(18)
        self.text = text
        self.frame = frame
        self.textColor = UIColor.blackColor()
    }
}

class PainLevel: UIView, SelectorDelegate {

    var successAlertView:UIAlertView?
    var errorAlertView:UIAlertView?
    var painSlider: UISlider?
    var hurtLabel:PainLabel?
    var checkLabel:PainLabel?
    let mSelectorTitles = ["Throb", "Burn", "Sharp","Ache"];
    var boxes:[Selector]?
    var log:Button?
    var cancel:Button?
    var painLog: PostReq?
    var post:NSString?
    var url:String?
    var painP = PainProccess()
    
    func clear(){
        self.painSlider?.value = 0
        self.painSlider?.tintColor = customColor.firstBlue
        self.setStates([0,0,0,0])
    }
    
    func setUp(frame:CGRect){
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        self.post = "session_key=\(session_key)&data=None"
        self.url = c.ip+"/ptapi/logPain"
        self.painLog = PostReq(post:self.post!, url:self.url!)
        self.successAlertView = UIAlertView()
        self.successAlertView?.title = "Pain Logged"
        self.successAlertView?.message = "Your Pain was Logged"
        self.successAlertView?.delegate = self
        self.successAlertView?.addButtonWithTitle("OK")
        self.errorAlertView?.title = "A Problem Occured!"
        self.errorAlertView?.message = "Your Pain was not logged"
        self.errorAlertView?.delegate = self
        self.errorAlertView?.addButtonWithTitle("OK")
        self.hurtLabel = PainLabel()
        self.hurtLabel?.setUp("Pain Level:", frame: CGRectMake(20, 10, 250, 30))
        self.addSubview(hurtLabel!)
        self.painSlider = UISlider()
        self.painSlider?.frame = CGRectMake(20, 45, 250, 30)
        self.addSubview(self.painSlider!)
        self.checkLabel = PainLabel()
        self.checkLabel?.setUp("Pain Type:", frame: CGRectMake(20, 90, 250, 30))
        self.addSubview(checkLabel!)
        self.boxes = createSelectors()
        self.log = Button()
        self.log?.setUp("Log Pain", frame: CGRectMake(180, 170, 100, 30))
        self.log?.addTarget(self, action:"logTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.log?.backgroundColor = customColor.red
        self.addSubview(self.log!)
        self.cancel = Button()
        self.cancel?.setUp("Cancel", frame: CGRectMake(20, 170, 100, 30))
        self.cancel?.addTarget(self, action:"cancelTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        //self.cancel?.backgroundColor = customColor.firstBlue
        self.addSubview(self.cancel!)
        self.frame = frame
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        
    }
    
    func logTapped(sender:Button!){
        println("Logit!")
        var states:[Float] = self.getStates()
        states.append(self.painSlider!.value)
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var format = NSDateFormatter()
        format.dateFormat  = "yyyy-MM-dd"
        var hour = NSDateFormatter()
        hour.dateFormat = "HH"
        self.post = "session_key=\(session_key)&time=\(format.stringFromDate((NSDate())))&hour=\(hour.stringFromDate(NSDate()))&data=\(states)"
        self.url = c.ip+"/ptapi/logPain"
        painLog?.update(self.post!, url:self.url!)
        var success = painLog?.Post(painP)
        //if success == 1{
         //   self.addSubview(successAlertView!)
          //  self.successAlertView?.show()
        //}
        //else{
         //   self.errorAlertView?.show()
        //}
        self.removeFromSuperview()
    }
    
    func cancelTapped(sender:Button!){
        println("cancel!")
        self.removeFromSuperview()
    }
    
    func createSelectors() -> [Selector] {
        var boxes:[Selector] = []
        let lNumberOfSelectors = 4;
        let lSelectorHeight: CGFloat = 20.0;
        var lFrame = CGRectMake(20, 125, 60, lSelectorHeight);
        for (var counter = 0; counter < lNumberOfSelectors; counter++) {
            var lSelector = Selector(frame: lFrame, title: mSelectorTitles[counter], selected: false);
            lSelector.mDelegate = self;
            lSelector.tag = counter;
            boxes.append(lSelector)
            self.addSubview(lSelector);
            lFrame.origin.x += lFrame.size.width + 5;
            if((counter + 1) % 10 == 0)
            {
                lFrame.origin.x = 20
                lFrame.origin.y += lFrame.size.height + 10
            }
        }
        return boxes
    }
    
    func didSelectSelector(state: Bool, identifier: Int, title: String) {
        println("Selector '\(title)' has state \(state)");
    }
    
    func getStates() -> [Float]{
        var states:[Float] = []
        for var i=0; i<self.boxes?.count; i=i+1{
            if self.boxes?[i].selected == true{
                states.append(1.0)
            }
            else{
                states.append(0.0)
            }
        }
        return states
    }
    
    func setStates(sel:[Int]){
        for var i=0; i<self.boxes?.count; i=i+1{
            if sel[i] == 1{
                self.boxes?[i].selected = true
            }
            else{
                self.boxes?[i].selected = false
            }
        }
    }
    
    class PainProccess: Processor{
        override func processData(data: NSDictionary) {
            super.processData(data)
            println("pain proccessor")
        }
    }
}

class AchieveAlert: UIView {
    
    var nameLabel:ALabel?
    var descriptLabel:ALabel?
    var ok:Button?
    
    func update(name:String, des:String){
        self.nameLabel?.text = name
        self.descriptLabel?.text = des
        
    }
    
    func setUp(frame:CGRect, name:String, des:String, aP:AchProc){
        self.nameLabel = ALabel()
        self.nameLabel?.setUp("name",frame:CGRectMake(20, 10, 250, 30))
        self.descriptLabel = ALabel()
        self.descriptLabel?.setUp("desc", frame:CGRectMake(20, 35, 250, 40))
        self.addSubview(nameLabel!)
        self.addSubview(descriptLabel!)
        self.ok = Button()
        self.ok?.setUp("OK",frame: CGRectMake(50, 80, 200, 30))
        self.ok?.addTarget(self, action:"done:", forControlEvents: UIControlEvents.TouchUpInside)
        self.ok?.backgroundColor = customColor.firstBlue
        self.addSubview(self.ok!)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        self.frame = frame

        
    }
    
    func done(sender:UIButton){
        self.removeFromSuperview()
    }
}



class ExerciseAlert: UIView {
    var nameLabel:ExerciseLabel?
    var sets:ExerciseLabel?
    var exerciseComplete:Button?
    var exerciseHalf:Button?
    var exerciseSkip:Button?
    var exerciseId: Int?
    var ePost: PostReq?
    var post:NSString?
    var url:String?
    var eProc: ExerciseProc?
    var urlString:String?
    var urlButton:Button?
    
    func update(name:String,setReps:String, exercise_id:Int, urlString:String){
        self.nameLabel?.text = name
        self.sets?.text = setReps
        self.exerciseId = exercise_id as Int
        
        self.urlString? = urlString
        
        if self.urlString? == ""{
            self.urlButton?.setTitle("No Link Provided", forState: UIControlState.Normal)
            self.urlButton?.removeTarget(self, action: "lookup:", forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        else {
            self.urlButton?.setTitle("Link to Exercise Description", forState: UIControlState.Normal)
            self.urlButton?.addTarget(self, action: "lookup:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
    }
    
    deinit{
        println("destroyed")
    }
    
    func setUp(frame:CGRect, name:String, setReps:String, urlString:String, eP:ExerciseProc){
        self.eProc = eP
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        self.post = "session_key=\(session_key)&data=None"
        self.url = c.ip+"/ptapi/addNewInstance"
        self.ePost = PostReq(post: post!, url: url!)
        self.nameLabel = ExerciseLabel()
        self.nameLabel?.setUp("name",frame:CGRectMake(20, 10, 250, 30))
        self.sets = ExerciseLabel()
        self.sets!.setUp(setReps, frame: CGRectMake(20, 40, 250, 30))
        self.addSubview(nameLabel!)
        self.addSubview(sets!)
        self.urlString = urlString
        self.urlButton = Button()
        self.urlButton?.setUp(self.urlString!, frame: CGRectMake(20, 80, 250, 30))
        self.urlButton?.backgroundColor = customColor.firstBlue
        self.addSubview(self.urlButton!)
        self.exerciseComplete = Button()
        self.exerciseComplete?.setUp("Completed",frame: CGRectMake(190, 130, 80, 30))
        self.exerciseComplete?.addTarget(self, action:"Completed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.exerciseComplete?.backgroundColor = customColor.firstBlue
        self.exerciseSkip = Button()
        self.exerciseSkip?.setUp("Skipped",frame: CGRectMake(20, 130, 80, 30))
        self.exerciseSkip?.addTarget(self, action:"Skipped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.exerciseSkip?.backgroundColor = customColor.red
        self.exerciseHalf = Button()
        self.exerciseHalf?.setUp("Attempted",frame: CGRectMake(105, 130, 80, 30))
        self.exerciseHalf?.addTarget(self, action:"Attempted:", forControlEvents: UIControlEvents.TouchUpInside)
        self.exerciseHalf?.backgroundColor = UIColor.grayColor()
        self.addSubview(exerciseComplete!)
        self.addSubview(exerciseSkip!)
        self.addSubview(exerciseHalf!)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        self.frame = frame
    }
    
    
    func lookup(sender:Button!){
        println(self.urlString!)
        UIApplication.sharedApplication().openURL(NSURL(string:self.urlString!)!)
    }
    
    func Completed(sender:Button!){
        println("Complete")
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var status = 2
        var date = eProc!.dateLabel!.text!
        var format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        self.post = "session_key=\(session_key)&exercise_id=\(self.exerciseId!)&exercise_completion=\(status)&exercise_date=\(date)&date=\(format.stringFromDate(NSDate()))"
        ePost?.update(post!, url: url!)
        ePost?.Post(eProc!)
        eProc!.current = 1
        self.removeFromSuperview()
    }
    
    func Attempted(sender:Button!){
        println("attempted")
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var status = 1
        var date = eProc!.dateLabel!.text!
        self.post = "session_key=\(session_key)&exercise_id=\(self.exerciseId!)&exercise_completion=\(status)&exercise_date=\(date)"
        ePost?.update(post!, url: url!)
        ePost?.Post(eProc!)
        eProc!.current = 1
        self.removeFromSuperview()
    }
    
    func Skipped(sender:Button!){
        println("skipped")
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var status = 0
        var date = eProc!.dateLabel!.text!
        self.post = "session_key=\(session_key)&exercise_id=\(self.exerciseId!)&exercise_completion=\(status)&exercise_date=\(date)"
        ePost?.update(post!, url: url!)
        ePost?.Post(eProc!)
        eProc!.current = 1
        self.removeFromSuperview()
    }

}

class AchProc: Processor{
    var items:[String]
    var nameToD:NSDictionary?
    var complete:[String]
    weak var table:UITableView?

    init(table:UITableView){
        self.items = []
        self.complete = []
        self.table = table
    }
    override func processData(data: NSDictionary) {
        super.processData(data)
        dispatch_async(dispatch_get_main_queue()) {
            self.nameToD = data.valueForKey("nameToD") as? NSDictionary
            self.complete = data.valueForKey("complete") as [String]
            self.items = data.valueForKey("complete") as [String]
            self.table!.reloadData()
            return Void()
        }
    }
}

class ExerciseProc: Processor{
    var eid: [Int]
    var date:[String]
    var items:[String]
    var repD:[String]
    var comp:[Int]
    var urlD:[String]
    weak var table:UITableView?
    var today:NSDictionary?
    var tomorrow:NSDictionary?
    var yesterday:NSDictionary?
    var current = 1
    var days:[NSDictionary]?
    weak var dateLabel:UILabel?
    
    init(table:UITableView, lab:UILabel){
        self.items = []
        self.repD = ["3 sets x 15 reps"]
        self.eid = [1]
        self.date = ["8/11"]
        self.comp = [1]
        self.urlD = []
        self.table = table
        self.dateLabel = lab
    }
    
    func next(){
        if self.current < 2{
            println("this should happen")
            self.current = self.current + 1
            self.items = self.days![self.current].valueForKey("exercise_name") as [String]
            self.repD = self.days![self.current].valueForKey("reps") as [String]
            self.eid = self.days![self.current].valueForKey("exercise_id") as [Int]
            self.comp = self.days![self.current].valueForKey("completion") as [Int]
            self.dateLabel?.text = self.days![self.current].valueForKey("date") as? String
            self.urlD = self.days![self.current].valueForKey("url") as [String]
            self.table!.reloadData()
        }
    }
    
    func prev(){
        
        if self.current > 0{
            self.current = self.current - 1
            self.items = self.days![self.current].valueForKey("exercise_name") as [String]
            self.repD = self.days![self.current].valueForKey("reps") as [String]
            self.eid = self.days![self.current].valueForKey("exercise_id") as [Int]
            self.comp = self.days![self.current].valueForKey("completion") as [Int]
            self.dateLabel?.text = self.days![self.current].valueForKey("date") as? String
            self.urlD = self.days![self.current].valueForKey("url") as [String]
            self.table!.reloadData()
        }
    }
    
    override func processData(data: NSDictionary) {
        super.processData(data)
        dispatch_async(dispatch_get_main_queue()) {
            self.today = data.valueForKey("td") as? NSDictionary
            self.tomorrow = data.valueForKey("rd") as? NSDictionary
            self.yesterday = data.valueForKey("yd") as? NSDictionary
            self.days = [self.yesterday!, self.today!, self.tomorrow!]
            self.items = self.today!.valueForKey("exercise_name") as [String]
            self.repD = self.today!.valueForKey("reps") as [String]
            self.eid = self.today!.valueForKey("exercise_id") as [Int]
            self.comp = self.today!.valueForKey("completion") as [Int]
            self.dateLabel?.text = self.today!.valueForKey("date") as? String
            self.urlD = self.today!.valueForKey("url") as [String]
            self.table!.reloadData()
            return Void()
        }
        
    }
    
}


@objc protocol SelectorDelegate {
    func didSelectSelector(state: Bool, identifier: Int, title: String);
}

class Selector: UIButton {
    weak var mDelegate: SelectorDelegate?;
    required init(coder: NSCoder) {
        super.init();
    }
    
    deinit{
        println("destroyed Selector")
    }
    init(frame: CGRect, title: String, selected: Bool) {
        super.init(frame: frame);
        self.adjustEdgeInsets();
        self.applyStyle();
        self.setTitle(title, forState: UIControlState.Normal);
        self.addTarget(self, action: "onTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside);
        println("created a selector")
    }
    
    func adjustEdgeInsets() {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
    }
    
    func applyStyle() {
        self.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal);
        self.setTitleColor(customColor.firstBlue, forState: UIControlState.Selected);
    }
    
    func onTouchUpInside(sender: UIButton) {
        self.selected = !self.selected;
        var titleString = self.titleLabel?.text
        mDelegate?.didSelectSelector(self.selected, identifier: self.tag, title: titleString!);
    }
}



class PostReq{
    var url:NSURL
    var request:NSMutableURLRequest
    var jsonData:NSDictionary?
    var queue:NSOperationQueue?
    var postData:NSData?
    var postLength:NSString?
    var achAlert:UIAlertView = UIAlertView()

    
    deinit{
        println("deleted requestttt")
    }
    
    init(post:NSString, url:String){
        self.url = NSURL(string: url)!
        self.request = NSMutableURLRequest(URL: self.url)
        self.request.HTTPMethod = "POST"
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.queue  = NSOperationQueue()
        self.postData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        self.postLength = String( postData!.length )
        self.achAlert.title = "Achievement Unlocked!"
        self.achAlert.message = "You have unlocked a new achivemet! View it on your achievments page"
        self.achAlert.addButtonWithTitle("OK")
        
    }
    
    func update(post:NSString, url:String){
        self.postData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        self.postLength = String( self.postData!.length )
        self.url = NSURL(string: url)!
        self.request = NSMutableURLRequest(URL: self.url)
        self.request.HTTPMethod = "POST"
        self.request.HTTPBody = self.postData
        self.request.setValue(self.postLength, forHTTPHeaderField: "Content-Length")
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")

    }
    
    func Post(obj:Processor) -> Int {
        var success:Int = 0
        println(self.request.HTTPBody)
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if (error != nil) {
                println("API error: \(error), \(error.userInfo)")
            }
            else{
                var jsonError:NSError?
                println(response)

                self.jsonData = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary

                obj.processData(self.jsonData!)
                if (jsonError != nil) {
                    println("Error parsing json: \(jsonError)")
                    success = 0
                }
                if (self.jsonData?.valueForKey("success") as Int == 1){
                    success = 1
                }
                if (self.jsonData?.valueForKey("success") as Int == 4){
                    success = 1
                    obj.processData(self.jsonData!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.achAlert.show()
                    }
                }
                else{
                    success = 0
                }
            }
        })
    return success
    }
}

class Processor {
    func processData(data:NSDictionary){
        println(data)
    }
}

class asProcessor:Processor{
    deinit{
        println("process deleted")
    }
    override func processData(data: NSDictionary) {
        super.processData(data)
        var success:NSInteger = data.valueForKey("success") as NSInteger
        if(success == 1)
        {
            NSLog("Sign Up SUCCESS");
        } else {
            var error_msg:NSString
            if data["error_message"] as? NSString != nil {
                error_msg = data["error_message"] as NSString
            } else {
                error_msg = "PT Username Not Found"
            }
        }
    }
}


class GetReq{
    var url:NSURL
    var request:NSMutableURLRequest
    var jsonData:NSDictionary?
    var queue:NSOperationQueue?
    var postData:NSData?
    var postLength:NSString?
    var achAlert:UIAlertView = UIAlertView()
    
    deinit{
        println("deleted Getrequestttt")
    }
    
    init(post:NSString, url:String){
        self.url = NSURL(string: url+post)!
        self.request = NSMutableURLRequest(URL: self.url)
        self.request.HTTPMethod = "GET"
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.queue  = NSOperationQueue()
        self.achAlert.title = "Achievement Unlocked!"
        self.achAlert.message = "You have unlocked a new achivemet! View it on your achievments page"
        self.achAlert.addButtonWithTitle("OK")
        

    }
    
    func update(post:NSString, url:String){
        self.url = NSURL(string: url+post)!
        self.request = NSMutableURLRequest(URL: self.url)
        self.request.HTTPMethod = "GET"
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.request.setValue("application/json", forHTTPHeaderField: "Accept")

    }
    
    func Get(obj:Processor) -> Int {
        var success:Int = 0
        println(self.request.HTTPBody)
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if (error != nil) {
                println("API error: \(error), \(error.userInfo)")
            }
            else{
                var jsonError:NSError?
                
                self.jsonData = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                println(self.url)
                
                if (jsonError != nil) {
                    println("Error parsing json: \(jsonError)")
                    success = 0
                }
                if (self.jsonData?.valueForKey("success") as Int == 1){
                    success = 1
                    obj.processData(self.jsonData!)
                }
                if (self.jsonData?.valueForKey("success") as Int == 4){
                    success = 1
                    obj.processData(self.jsonData!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.achAlert.show()
                    }
                }
                else{
                    success = 0
                }
            }
        })
        return success
    }
}



