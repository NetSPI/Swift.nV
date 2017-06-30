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
        registerScroll.contentSize = CGSize(width: 241, height: 450)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(_ sender : AnyObject) {
        if (self.email.text == "") ||
           (self.password1.text == "") ||
           (self.password2.text == "") ||
           (self.firstname.text == "") ||
            (self.lastname.text == "") {
                self.message.text = "all fields required"
        } else if self.password1.text != self.password2.text {
            self.message.text = "passwords must match"
        } else {
            self.message.text = "registering \(String(describing: self.email.text))"
            //NSLog("registering \(self.email.text)")
            
            let defaults : UserDefaults = UserDefaults.standard
            
            let useNetwork = defaults.bool(forKey: "networkStorage")
            if (useNetwork) {
                let user = [
                    "email": self.email.text!,
                    "fname": self.firstname.text!,
                    "lname": self.lastname.text!,
                    "password": self.password1.text!
                ]
            
                NSLog("u: \(user)")
                var j: Data?
                do {
                    j = try JSONSerialization.data(withJSONObject: user, options: JSONSerialization.WritingOptions.prettyPrinted)
                } catch let error as NSError {
                    NSLog("Error: %@", error)
                    j = nil
                }
            
                let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
                let envs = NSDictionary(contentsOfFile: envPlist!)!
                let tURL = envs.value(forKey: "RegisterURL") as! String
                let regURL = URL(string: tURL)
            
                NSLog("registering \(String(describing: self.email.text)) with \(String(describing: regURL))")
            
                var request = URLRequest(url: regURL!)
                request.httpMethod = "POST"
                request.httpBody = j
                //_ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    if let error = error {
                        NSLog("DataTask error: " + error.localizedDescription)
                    } else {
                        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                        
                        if( res["id"] != nil) {
                            self.message.text = "success"
                            self.dismiss(animated: true, completion: nil)
                            
                        } else {
                            self.message.text = "error"
                        }
                    }
                    
                }).resume()
            } else {
                
                let u = registerUser(self.email.text!, self.password1.text!, self.firstname.text!, self.lastname.text!, nil,nil)
                
                if (u != nil) {
                    self.message.text = "success"
                } else {
                    self.message.text = "error"
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancel(_ sender : AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
