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
        
        let hvc : NVHomeViewController = self.parent as! NVHomeViewController
        
        let u : User = hvc.appUser as User!
        // Do any additional setup after loading the view.
        if u.email == "" {
            // Uhhh, how did this happen?
            self.userLabel.text = "not logged in"
        } else {
            self.userLabel.text = u.email
            self.firstLabel.text = u.firstname
            self.lastLabel.text = u.lastname
            remember.isOn = UserDefaults.standard.bool(forKey: "loggedin")
            networkStorage.isOn = UserDefaults.standard.bool(forKey: "networkStorage")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender : AnyObject) {
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set(false, forKey: "loggedin")
        UserDefaults.standard.synchronize()
        //var parent = self.parentViewController
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func rememberMe(_ sender : AnyObject) {
        UserDefaults.standard.set(remember.isOn, forKey: "loggedin")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func toggleNetwork(_ sender: AnyObject) {
        UserDefaults.standard.set(networkStorage.isOn, forKey: "networkStorage")
        UserDefaults.standard.synchronize()
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
