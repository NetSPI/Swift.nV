//
//  NVLoginViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 6/24/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVLoginViewController: UIViewController {

    @IBOutlet var message : UILabel!
    @IBOutlet var username : UITextField!
    @IBOutlet var password : UITextField!
    @IBOutlet var goButton : UIButton!
    @IBOutlet var register : UIButton!
    
    var appUser : User!
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        self.message.text = "Logging in as \(self.username.text)"
        // authenticate here!!!
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext

        let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "(email LIKE '\(self.username.text)') AND (password LIKE '\(self.password.text)')",argumentArray: nil)
        NSLog("Predicate %@",fr.predicate)
        
        var error:NSError? = nil
        var users : NSArray = context.executeFetchRequest(fr, error: &error)
        
        var auth = false
        if users.count > 0 {
            NSLog("auth (\(self.username.text):\(self.password.text))")
            appUser = users[0] as? User
            var te : NSString = self.username.text
            var defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(te, forKey: "email")
            defaults.setBool(true, forKey: "loggedin")
            defaults.synchronize()
            NSLog("Setting email key in NSUserDefaults to \(te)")
            //NSLog("Defaults: %@",defaults)
            
            self.performSegueWithIdentifier("Home", sender: self)
            auth = true
            
        } else {
            NSLog("auth failed (\(self.username.text):\(self.password.text))")
            self.message.text = "auth failed"
        }
    
    }

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Home") {
            var dv : NVHomeViewController = segue.destinationViewController as NVHomeViewController
            NSLog("passing \(self.appUser.email) (\(self.appUser.firstname) \(self.appUser.lastname))")
            dv.appUser = self.appUser
        }
    }

}
