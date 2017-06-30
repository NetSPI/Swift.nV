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
    @IBOutlet var pinSwitch: UISwitch!
    
    var appUser : User!
    
    var data = NSMutableData()
    
    @IBAction func go(_ sender : AnyObject) {
        if self.username.text == "" || self.password.text == "" {
            self.message.text = "username & password required"
        } else {
            login()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        self.message.text = "Logging in as \(self.username.text!)"
        
        let defaults : UserDefaults = UserDefaults.standard
        
        let useNetwork = defaults.bool(forKey: "networkStorage")
        
        if (useNetwork) {
            // networkStorage is setup, let's use it!
            let authRequest = [
                "email": self.username.text!,
                "password": self.password.text!
            ]
        
            var j: Data?
            do {
                j = try JSONSerialization.data(withJSONObject: authRequest, options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch let error as NSError {
                NSLog("Error: %@", error);
                j = nil
            }
        
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            let tURL = envs.value(forKey: "AuthenticateURL") as! String
            let authURL = URL(string: tURL)
        
            #if DEBUG
                NSLog("authenticate \(self.username.text!) with \(authURL!)")
            #endif
        
            var request = URLRequest(url: authURL!)
            request.httpMethod = "POST"
            request.httpBody = j
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let error = error {
                    NSLog("DataTask error: " + error.localizedDescription)
                } else {
                    _ = NSString(data: self.data as Data, encoding: String.Encoding.utf8.rawValue)
                    //NSLog("response: \(resStr)")
                    
                    let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    
                    if (res["error"] != nil) {
                        self.message.text = res["error"] as? String
                        self.data.setData(Data())
                    } else if (res["id"] != nil) {
                        // User Authenticated. Make sure they exist in the DB and log them in.
                        var user :User? = getUser(self.username.text!)
                        
                        if user != nil {
                            self.appUser = user!
                            
                        } else {
                            NSLog("user \(String(describing: self.username.text)) does not exist, storing")
                            user = registerUser((res["email"] as? String)!, self.password.text!, (res["fname"] as? String)!, (res["lname"] as? String)!, res["api_token"] as? String, Int32(res["id"] as! NSNumber))
                            
                            self.appUser = user!
                            
                        }
                        
                        let defaults = UserDefaults.standard
                        defaults.set(self.username.text! as NSString, forKey: "email")
                        defaults.set(true, forKey: "loggedin")
                        defaults.synchronize()
                        NSLog("Setting email key in NSUserDefaults to \(String(describing: self.username.text))")
                        
                        self.data.setData(Data())
                        self.performSegue(withIdentifier: "Home", sender: self)
                    } else {
                        self.data.setData(Data())
                        self.message.text = "error"
                    }
                }
                
            }).resume()
        } else {
            // no network storage, let's use local auth
            NSLog("Login \(String(describing: self.username.text!)):\(String(describing: self.password.text!))")
            
            if (getUser(self.username.text!) != nil) {
                let user: User? = authenticateUser(self.username.text!, self.password.text!)
            
                if user != nil {
                    // User successfully authenticated
                    self.appUser = user!
                
                    self.performSegue(withIdentifier: "Home", sender: self)
                
                } else {
                    self.message.text = "Login failed"
                }
            } else {
                self.message.text = "Username not found"
            }
        }
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Home") {
            NSLog("passing \(String(describing: self.appUser.email!)) (\(String(describing: self.appUser.firstname!)) \(String(describing: self.appUser.lastname!)))")
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.appUser = self.appUser
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}

}
