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
    
    @IBOutlet weak var email : UITextField!
    @IBOutlet weak var password1 : UITextField!
    @IBOutlet weak var password2 : UITextField!
    @IBOutlet weak var firstname : UITextField!
    @IBOutlet weak var lastname : UITextField!
    @IBOutlet weak var message : UILabel!
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
            
            let user = [
                "email": self.email.text!,
                "fname": self.firstname.text!,
                "lname": self.lastname.text!,
                "password": self.password1.text!
            ]
            
            NSLog("u: \(user)")
            var j: NSData?
            do {
                j = try NSJSONSerialization.dataWithJSONObject(user, options: NSJSONWritingOptions.PrettyPrinted)
            } catch let error as NSError {
                NSLog("Error: %@", error)
                j = nil
            }
            
            let envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            let tURL = envs.valueForKey("RegisterURL") as! String
            let regURL = NSURL(string: tURL)
            
            NSLog("registering \(self.email.text) with \(regURL)")
            
            let request = NSMutableURLRequest(URL: regURL!)
            request.HTTPMethod = "POST"
            request.HTTPBody = j
            _ = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
    }

    @IBAction func cancel(sender : AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection, didReceiveData _data:NSData) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    /* func connection(con: NSURLConnection!, didReceiveResponse _response:NSURLResponse!) {
        NSLog("didReceiveResponse")
        var response : NSHTTPURLResponse = _response
        
    }*/
    
    func connectionDidFinishLoading(con: NSURLConnection) {
        let res : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
        if( res["id"] != nil) {
            self.message.text = "success"
            self.dismissViewControllerAnimated(true, completion: nil)

        } else {
            self.message.text = "error"
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.message.text = "Connection to API failed"
        NSLog("Error: %@",error)
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
