//
//  NVInitViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/3/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVInitViewController: UIViewController {

    @IBOutlet var message : UILabel!
    var email : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.message.text = "loading"
        var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("email") != nil {
            var email : NSString = defaults.stringForKey("email")! as NSString
            if email == "" {
                NSLog("email is blank")
            } else {
                NSLog("email in NSUserDefaults is '\(email)'")
            }
        } else {
                NSLog("no email in defaults, setting up storage")
                setupPreferences(defaults)
        }
        // NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("go"), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.go()
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: Selector("go"), userInfo: nil, repeats: false)
    }
    
    func setupPreferences(defaults: NSUserDefaults) {
        defaults.setObject("", forKey: "email")
        defaults.setBool(false, forKey: "loggedin")
        defaults.setBool(true, forKey: "networkStorage")

        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func go() {
        var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        self.email = defaults.stringForKey("email")! as NSString
        var loggedin :Bool = defaults.boolForKey("loggedin")
        if self.email == "" || !loggedin {
            self.performSegueWithIdentifier("InitLogin", sender: self)
        } else {
            self.performSegueWithIdentifier("InitHome", sender: self)
        }
    }
    
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {

        if (segue.identifier == "InitHome") {
            var dv : NVHomeViewController = segue.destinationViewController as NVHomeViewController
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "email LIKE '\(self.email)'", argumentArray: nil)
            
            var error:NSError? = nil
            var users : NSArray = context.executeFetchRequest(fr, error: &error)
            
            var user : User = users[0] as User
            
            NSLog("passing \(user.email) (\(user.firstname) \(user.lastname))")
            dv.appUser = user
        }
    }

}
