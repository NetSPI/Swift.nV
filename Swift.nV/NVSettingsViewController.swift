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
    @IBOutlet weak var remember : UISwitch!
    @IBOutlet weak var networkStorage: UISwitch!
    @IBOutlet weak var useFingerprint: UISwitch!
    @IBOutlet weak var enablePin: UISwitch!
    
    @IBOutlet weak var pinField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    var appUser: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (appUser == nil) {
            appUser = getUser(UserDefaults.standard.string(forKey: "email")!)
        }
        
        let u : User = appUser as User!
        // Do any additional setup after loading the view.
        if u.email == "" {
            // Uhhh, how did this happen?
            self.userLabel.text = "not logged in"
        } else {
            self.userLabel.text = u.email
            self.firstLabel.text = u.firstname! + " " + u.lastname!
            remember.isOn = UserDefaults.standard.bool(forKey: "loggedin")
            networkStorage.isOn = UserDefaults.standard.bool(forKey: "networkStorage")
            enablePin.isOn = UserDefaults.standard.bool(forKey: "usePin")
            pinField.text = UserDefaults.standard.string(forKey: "PIN")
            if ( enablePin.isOn ) {
                pinField.isHidden = false
                saveBtn.isHidden = false
            } else {
                pinField.isHidden = true
                saveBtn.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enablePinFunc(_ sender: Any) {
        NSLog("enablePinFunc")
        let enable = sender as! UISwitch
        if ( enable.isOn ) {
            pinField.isHidden = false
            saveBtn.isHidden = false
        } else {
            pinField.isHidden = true
            saveBtn.isHidden = true
        }
        UserDefaults.standard.set(enable.isOn, forKey: "usePin")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func pinSave(_ sender: Any) {
        NSLog("pinSave \(String(describing: pinField.text))")
        UserDefaults.standard.set(pinField.text, forKey: "PIN")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func logout(_ sender : AnyObject) {
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set(false, forKey: "loggedin")
        UserDefaults.standard.set(false, forKey: "usePin")
        UserDefaults.standard.set("1111", forKey: "PIN")
        UserDefaults.standard.synchronize()

        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }

    @IBAction func rememberMe(_ sender : AnyObject) {
        UserDefaults.standard.set(remember.isOn, forKey: "loggedin")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func toggleNetwork(_ sender: AnyObject) {
        
        let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        let tURL = envs.value(forKey: "AuthenticateURL") as! String
        let authURL = URL(string: tURL)
        
        var request = URLRequest(url: authURL!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let error = error {
                NSLog("DataTask error: " + error.localizedDescription)
                let alert : UIAlertController = UIAlertController(title: "Connection Failed", message: "Could not connect to API", preferredStyle: UIAlertControllerStyle.alert)
                let okItem : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
                {
                    (action:UIAlertAction) in
                    self.networkStorage.isOn = false
                    self.logout(self)
                })
                alert.addAction(okItem)
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(self.networkStorage.isOn, forKey: "networkStorage")
                UserDefaults.standard.synchronize()
            }
        }).resume()


    }
    
    @IBAction func toggleFingerprint(_ sender: AnyObject) {
        print("Fingerprint toggled")
        UserDefaults.standard.set(useFingerprint.isOn, forKey: "useFingerprint")
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
