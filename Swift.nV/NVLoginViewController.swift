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
    
    @IBAction func go(_ sender : AnyObject) {
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
        self.loginScroll.contentSize = CGSize(width: 320, height: 300)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func login() {
        self.message.text = "Logging in as \(self.username.text!)"
        
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
        
        NSLog("authenticate \(self.username.text!) with \(authURL!)")
        
        let request = NSMutableURLRequest(url: authURL!)
        request.httpMethod = "POST"
        request.httpBody = j
        
        _ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
    }

    
    // NSURLConnectionDataDelegate Classes
    
    func connection(_ con: NSURLConnection, didReceive _data:Data) {
        //NSLog("didReceiveData")
        self.data.append(_data)
    }
    
    func connectionDidFinishLoading(_ con: NSURLConnection) {
        //NSLog("connectionDidFinishLoading")
        _ = NSString(data: self.data as Data, encoding: String.Encoding.utf8.rawValue)
        //NSLog("response: \(resStr)")
        
        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        
        if (res["error"] != nil) {
            self.message.text = res["error"] as? String
            self.data.setData(Data())
        } else if (res["id"] != nil) {
            // User Authenticated. Make sure they exist in the DB and log them in.
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            //let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
            let fr:NSFetchRequest<NSFetchRequestResult>
            if #available(iOS 10.0, OSX 10.12, *) {
                fr = User.fetchRequest()
            } else {
                fr = NSFetchRequest(entityName: "User")
            }
            //let fr:NSFetchRequest<NSFetchRequestResult = User.FetchRequest(entityName:"User")
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "(email LIKE '\(self.username.text)')",argumentArray:  nil)
            
            let users : NSArray = try! context.fetch(fr) as NSArray
            
            if users.count > 0 {
                self.appUser = users[0] as? User
                
            } else {
                NSLog("user \(self.username.text) does not exist, storing")
                
                let user : User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
                
                //var uid : String = (res["id"] as NSNumber).stringValue
                user.email = res["email"] as! String
                user.password = self.password.text!
                user.firstname = res["fname"] as! String
                user.lastname = res["lname"] as! String
                user.user_id = res["id"] as! NSNumber
                user.token = res["api_token"] as! String
                
                do {
                    try context.save()
                } catch let error as NSError {
                    NSLog("Error saving context: %@", error)
                }
                
                self.appUser = user

            }
            
            let defaults = UserDefaults.standard
            defaults.set(self.username.text! as NSString, forKey: "email")
            defaults.set(true, forKey: "loggedin")
            defaults.synchronize()
            NSLog("Setting email key in NSUserDefaults to \(self.username.text)")
            
            //saveToKeychain("email", data: self.username.text!)
            
            self.data.setData(Data())
            self.performSegue(withIdentifier: "Home", sender: self)
        } else {
            self.data.setData(Data())
            self.message.text = "error"
        }
        
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.message.text = "Connection to API failed"
        print("%@",error)
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue.identifier == "Home") {
            let dv : NVHomeViewController = segue.destination as! NVHomeViewController
            NSLog("passing \(self.appUser.email) (\(self.appUser.firstname) \(self.appUser.lastname))")
            dv.appUser = self.appUser
        }
    }

}
