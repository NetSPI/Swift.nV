//
//  NVSettingsViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVSettingsViewController: UIViewController {

    @IBOutlet weak var userLabel : UILabel!
    @IBOutlet weak var firstLabel : UILabel!
    @IBOutlet weak var lastLabel : UILabel!
    @IBOutlet weak var remember : UISwitch!
    @IBOutlet weak var networkStorage: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hvc : NVHomeViewController = self.parentViewController as! NVHomeViewController
        
        var u : User = hvc.appUser as User!
        // Do any additional setup after loading the view.
        if u.email == "" {
            // Uhhh, how did this happen?
            self.userLabel.text = "not logged in"
        } else {
            self.userLabel.text = u.email
            self.firstLabel.text = u.firstname
            self.lastLabel.text = u.lastname
            remember.on = NSUserDefaults.standardUserDefaults().boolForKey("loggedin")
            networkStorage.on = NSUserDefaults.standardUserDefaults().boolForKey("networkStorage")
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
        //var parent = self.parentViewController
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func rememberMe(sender : AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(remember.on, forKey: "loggedin")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func toggleNetwork(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(networkStorage.on, forKey: "networkStorage")
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
