//
//  NVRegisterViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 6/25/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVRegisterViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var password1 : UITextField!
    @IBOutlet var password2 : UITextField!
    @IBOutlet var firstname : UITextField!
    @IBOutlet var lastname : UITextField!
    @IBOutlet var message : UILabel!
    @IBOutlet weak var registerScroll: UIScrollView!
    
    var data = NSMutableData()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerScroll.contentSize = CGSizeMake(241, 450)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender : AnyObject) {
        if (self.email.text == "") ||
           (self.password1.text == "") ||
           (self.password2.text == "") ||
           (self.firstname.text == "") ||
            (self.lastname.text == "") {
                self.message.text = "all fields required"
        } else if self.password1.text != self.password2.text {
            self.message.text = "passwords must match"
        } else {
            self.message.text = "registering \(self.email.text)"
            //NSLog("registering \(self.email.text)")
            
            var user = [
                "email": self.email.text,
                "fname": self.firstname.text,
                "lname": self.lastname.text,
                "password": self.password1.text
            ]
            
            NSLog("u: \(user)")
            var err:NSError? = nil
            var j = NSJSONSerialization.dataWithJSONObject(user, options: NSJSONWritingOptions.PrettyPrinted, error: &err)
            
            var envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
            var envs = NSDictionary(contentsOfFile: envPlist!)
            var tURL = envs.valueForKey("RegisterURL") as String
            var regURL = NSURL(string: tURL)
            
            NSLog("registering \(self.email.text) with \(regURL)")
            
            var request = NSMutableURLRequest(URL: regURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = j
            
            var queue = NSOperationQueue()
            var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
            
        }
    }

    @IBAction func cancel(sender : AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    /* func connection(con: NSURLConnection!, didReceiveResponse _response:NSURLResponse!) {
        NSLog("didReceiveResponse")
        var response : NSHTTPURLResponse = _response
        
    }*/
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        //NSLog("connectionDidFinishLoading")
        var resStr = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        //NSLog("response: \(resStr)")
        
        var res : NSDictionary = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if( res["id"] != nil) {
            self.message.text = "success"
            self.dismissViewControllerAnimated(true, completion: nil)

        } else {
            self.message.text = "error"
        }
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.message.text = "Connection to API failed"
        NSLog("%@",error!)
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
