//
//  CustomModels.swift
//  PatientPortal
//
//  Created by Joseph Driscoll on 1/17/15.
//  Copyright (c) 2015 Joseph Driscoll. All rights reserved.
//

import UIKit
import Foundation

class Button: UIButton {
    
    func setUp(title:NSString,frame:CGRect){
        self.backgroundColor = UIColor.lightGrayColor()
        self.setTitle(title, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(14)
        self.frame = frame
        self.layer.cornerRadius = 5

    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}

class ExerciseLabel: UILabel {
    
    func setUp(text:String,frame:CGRect){
        self.font = UIFont.systemFontOfSize(20)
        self.text = text
        self.frame = frame
        self.textColor = UIColor.blueColor()
    }
}

class PainLabel: UILabel {
    
    func setUp(text:String,frame:CGRect){
        self.font = UIFont.systemFontOfSize(18)
        self.text = text
        self.frame = frame
        self.textColor = UIColor.lightGrayColor()
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
    var painLog = PainPost()
    
    
    func clear(){
        self.painSlider?.value = 0
        self.setStates([0,0,0,0])
    }
    
    func setUP(frame:CGRect){
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
        self.addSubview(self.log!)
        self.cancel = Button()
        self.cancel?.setUp("Cancel", frame: CGRectMake(20, 170, 100, 30))
        self.cancel?.addTarget(self, action:"cancelTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.cancel!)
        self.frame = frame
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        
    }
    
    func logTapped(sender:Button!){
        println("Logit!")
        var states:[Float] = self.getStates()
        states.append(self.painSlider!.value)
        painLog.update(states)
        var success = painLog.PostPain()
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
    
    class PainPost{
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var post:NSString
        var url:NSURL
        var request:NSMutableURLRequest
        var jsonData:NSDictionary?
        var queue:NSOperationQueue?
        var postData:NSData?
        var postLength:NSString?
        
        init(){
            println("initialized request")
            self.post = "session_key=\(session_key)&data=None"
            self.url = NSURL(string: "http://localhost:8000/ptapi/logPain")!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "POST"
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
            self.queue  = NSOperationQueue()
            self.postData = self.post.dataUsingEncoding(NSASCIIStringEncoding)!
            self.postLength = String( postData!.length )
            
        }
        
        func update(states:[Float]){
            self.session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
            self.post = "session_key=\(session_key)&data=\(states)"
            self.postData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            self.postLength = String( self.postData!.length )
            self.url = NSURL(string: "http://localhost:8000/ptapi/logPain")!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "POST"
            self.request.HTTPBody = self.postData
            self.request.setValue(self.postLength, forHTTPHeaderField: "Content-Length")
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        func PostPain() -> Int {
            var success:Int = 0
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if (error != nil) {
                    println("API error: \(error), \(error.userInfo)")
                }
                var jsonError:NSError?
                println("hihihihihi")
                println(data)
                println(self.request.HTTPMethod)
                self.jsonData = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                if (jsonError != nil) {
                    println("Error parsing json: \(jsonError)")
                    success = 0
                }
                println(self.jsonData!)
                if (self.jsonData?.valueForKey("success") as Int == 1){
                    success = 1
                }
                else{
                    success = 0
                }
            })
            return success
        }
    }
}

class ExerciseAlert: UIView {
    var nameLabel:ExerciseLabel?
    var sets:ExerciseLabel?
    var exerciseComplete:Button?
    var exerciseHalf:Button?
    var exerciseSkip:Button?
    var exerciseId: Int?
    var ePost = EStatusPost()
    
    func update(name:String,setReps:String, exercise_id:Int){
        self.nameLabel?.text = name
        self.sets?.text = setReps
        self.exerciseId = exercise_id
    }
    
    deinit{
        println("destroyed")
    }
    
    func setUp(frame:CGRect, name:String, setReps:String){
        self.nameLabel = ExerciseLabel()
        self.nameLabel?.setUp("name",frame:CGRectMake(20, 10, 250, 30))
        self.sets = ExerciseLabel()
        self.sets?.setUp(setReps, frame: CGRectMake(20, 40, 250, 30))
        self.addSubview(nameLabel!)
        self.addSubview(sets!)
        self.exerciseComplete = Button()
        self.exerciseComplete?.setUp("Completed",frame: CGRectMake(190, 80, 80, 30))
        self.exerciseComplete?.addTarget(self, action:"Completed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.exerciseSkip = Button()
        self.exerciseSkip?.setUp("Skipped",frame: CGRectMake(20, 80, 80, 30))
        self.exerciseSkip?.addTarget(self, action:"Skipped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.exerciseHalf = Button()
        self.exerciseHalf?.setUp("Attempted",frame: CGRectMake(105, 80, 80, 30))
        self.exerciseHalf?.addTarget(self, action:"Attempted:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(exerciseComplete!)
        self.addSubview(exerciseSkip!)
        self.addSubview(exerciseHalf!)
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 10
        self.frame = frame
        
    }
    
    func Completed(sender:Button!){
        println("Complete")
        ePost.update(self.exerciseId!, status:2)
        ePost.PostStatus()
        self.removeFromSuperview()
        
    }
    
    func Attempted(sender:Button!){
        println("attempted")
        ePost.update(self.exerciseId!, status:1)
        ePost.PostStatus()
        self.removeFromSuperview()
    }
    
    func Skipped(sender:Button!){
        println("skipped")
        ePost.update(self.exerciseId!, status:0)
        ePost.PostStatus()
        self.removeFromSuperview()
    }
    
    class EStatusPost{
        var session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
        var post:NSString
        var url:NSURL
        var request:NSMutableURLRequest
        var jsonData:NSDictionary?
        var queue:NSOperationQueue?
        var postData:NSData?
        var postLength:NSString?
        
        init(){
            println("initialized request")
            self.post = "session_key=\(session_key)&data=None"
            self.url = NSURL(string: "http://localhost:8000/ptapi/updateExercise")!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "POST"
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
            self.queue  = NSOperationQueue()
            self.postData = self.post.dataUsingEncoding(NSASCIIStringEncoding)!
            self.postLength = String( postData!.length )
            
        }
        
        func update(exercise_id:Int, status:Int){
            self.session_key = NSUserDefaults.standardUserDefaults().valueForKey("SESSION_KEY") as NSString
            self.post = "session_key=\(session_key)&exercise_id=\(exercise_id)&status=\(status)"
            self.postData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            self.postLength = String( self.postData!.length )
            self.url = NSURL(string: "http://localhost:8000/ptapi/updateExercise")!
            self.request = NSMutableURLRequest(URL: self.url)
            self.request.HTTPMethod = "POST"
            self.request.HTTPBody = self.postData
            self.request.setValue(self.postLength, forHTTPHeaderField: "Content-Length")
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        func PostStatus() -> Int {
            var success:Int = 0
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if (error != nil) {
                    println("API error: \(error), \(error.userInfo)")
                }
                var jsonError:NSError?
                println("hihihihihi")
                println(data)
                println(self.request.HTTPMethod)
                self.jsonData = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                if (jsonError != nil) {
                    println("Error parsing json: \(jsonError)")
                    success = 0
                }
                if (self.jsonData?.valueForKey("success") as Int == 1){
                    success = 1
                }
                else{
                    success = 0
                }
            })
            return success
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
    }
    
    func adjustEdgeInsets() {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
    }
    
    func applyStyle() {
        self.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
        self.setTitleColor(UIColor.redColor(), forState: UIControlState.Selected);
    }
    
    func onTouchUpInside(sender: UIButton) {
        // #7
        self.selected = !self.selected;
        // #8
        var titleString = self.titleLabel?.text
        mDelegate?.didSelectSelector(self.selected, identifier: self.tag, title: titleString!);
    }
}
