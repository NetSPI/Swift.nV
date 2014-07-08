//
//  NVSettingsViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVSettingsViewController: UIViewController {

    @IBOutlet var userLabel : UILabel
    @IBOutlet var firstLabel : UILabel
    @IBOutlet var lastLabel : UILabel
    @IBOutlet var remember : UISwitch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hvc : NVHomeViewController = self.parentViewController as NVHomeViewController
        
        var u : User = hvc.appUser as User!
        // Do any additional setup after loading the view.
        if u == nil {
            // Uhhh, how did this happen?
            self.userLabel.text = "not logged in"
        } else {
            self.userLabel.text = u.email
            self.firstLabel.text = u.firstname
            self.lastLabel.text = u.lastname
            remember.on = NSUserDefaults.standardUserDefaults().boolForKey("loggedin")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender : AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "email")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "loggedin")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissModalViewControllerAnimated(true)
    }

    @IBAction func rememberMe(sender : AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(remember.on, forKey: "loggedin")
        NSUserDefaults.standardUserDefaults().synchronize()
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
