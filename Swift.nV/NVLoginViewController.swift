//
//  NVLoginViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 6/24/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVLoginViewController: UIViewController, NSURLConnectionDataDelegate {

    @IBOutlet weak var message : UILabel!
    @IBOutlet weak var username : UITextField!
    @IBOutlet weak var password : UITextField!
    @IBOutlet weak var goButton : UIButton!
    @IBOutlet weak var register : UIButton!
    @IBOutlet weak var loginScroll: UIScrollView!
    
    var appUser : User!
    
    var data = NSMutableData()
    
    @IBAction func go(sender : AnyObject) {
        //if self.username.text == "" {
        //    self.message.text = "username & password required"
        //} else if self.password.text == "" {
        //    self.message.text = "username & password required"
        //} else {
            login()
        //}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginScroll.contentSize = CGSizeMake(320, 300)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        self.message.text = "Logging in as \(self.username.text)"
        
        var authRequest = [
            "email": self.username.text,
            "password": self.password.text
        ]
        
        var err:NSError? = nil
        var j = NSJSONSerialization.dataWithJSONObject(authRequest, options: NSJSONWritingOptions.PrettyPrinted, error: &err)
        
        var envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
        var envs = NSDictionary(contentsOfFile: envPlist!)
        var tURL = envs.valueForKey("AuthenticateURL") as String
        var authURL = NSURL(string: tURL)
        
        NSLog("authenticate \(self.username.text) with \(authURL)")
        
        var request = NSMutableURLRequest(URL: authURL)
        request.HTTPMethod = "POST"
        request.HTTPBody = j
        
        var queue = NSOperationQueue()
        var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
    }

    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        //NSLog("connectionDidFinishLoading")
        var resStr = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        //NSLog("response: \(resStr)")
        
        var res : NSDictionary = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if (res["error"] != nil) {
            self.message.text = res["error"] as? String
            self.data.setData(NSData())
        } else if (res["id"] != nil) {
            // User Authenticated. Make sure they exist in the DB and log them in.
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "(email LIKE '\(self.username.text)')",argumentArray:  nil)
            
            var error:NSError? = nil
            var users : NSArray = context.executeFetchRequest(fr, error: &error)!
            
            var auth = false
            if users.count > 0 {
                self.appUser = users[0] as? User
                auth = true
                
            } else {
                NSLog("user \(self.username.text) does not exist, storing")
                
                var user : User = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as User
                
                //var uid : String = (res["id"] as NSNumber).stringValue
                user.email = res["email"] as String
                user.password = self.password.text
                user.firstname = res["fname"] as String
                user.lastname = res["lname"] as String
                user.user_id = res["id"] as NSNumber
                user.token = res["api_token"] as String
                
                var err:NSError? = nil
                context.save(&err)
                
                if err != nil {
                    NSLog("%@",err!)
                }
                
                self.appUser = user

            }
            
            var defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.username.text as NSString, forKey: "email")
            defaults.setBool(true, forKey: "loggedin")
            defaults.synchronize()
            NSLog("Setting email key in NSUserDefaults to \(self.username.text)")
            
            self.data.setData(NSData())
            self.performSegueWithIdentifier("Home", sender: self)
        } else {
            self.data.setData(NSData())
            self.message.text = "error"
        }
        
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.message.text = "Connection to API failed"
        NSLog("%@",error!)
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Home") {
            var dv : NVHomeViewController = segue.destinationViewController as NVHomeViewController
            NSLog("passing \(self.appUser.email) (\(self.appUser.firstname) \(self.appUser.lastname))")
            dv.appUser = self.appUser
        }
    }

}
