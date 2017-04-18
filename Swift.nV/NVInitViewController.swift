//
//  NVInitViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/3/14.
//  Copyright (c) 2016 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVInitViewController: UIViewController {

    @IBOutlet var message : UILabel!
    var email : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.message.text = "loading"
        let defaults : UserDefaults = UserDefaults.standard
        if defaults.object(forKey: "email") != nil {
            let email : NSString = defaults.string(forKey: "email")! as NSString
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.go()
        Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(NVInitViewController.go), userInfo: nil, repeats: false)
    }
    
    func setupPreferences(_ defaults: UserDefaults) {
        defaults.set("", forKey: "email")
        defaults.set(false, forKey: "loggedin")
        defaults.set(true, forKey: "networkStorage")

        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func go() {
        let defaults : UserDefaults = UserDefaults.standard
        self.email = defaults.string(forKey: "email")! as NSString
        if ( self.email != "" ) {
            NSLog("Logged in email is \(self.email)")
        } else {
            self.email = ""
            NSLog("Not currently logged in")
        }
        let loggedin :Bool = defaults.bool(forKey: "loggedin")
        if self.email == "" || !loggedin {
            self.performSegue(withIdentifier: "InitLogin", sender: self)
        } else {
            self.performSegue(withIdentifier: "InitHome", sender: self)
        }
    }
    
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "InitHome") {
            let dv : NVHomeViewController = segue.destination as! NVHomeViewController
            
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest<NSFetchRequestResult>
            if #available(iOS 10.0, OSX 10.12, *) {
                fr = User.fetchRequest()
            } else {
                fr = NSFetchRequest(entityName: "User")
            }
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "email LIKE '\(self.email)'", argumentArray: nil)
            
            let users : NSArray = try! context.fetch(fr) as NSArray
            
            let user : User = users[0] as! User
            
            NSLog("passing \(user.email) (\(user.firstname) \(user.lastname))")
            dv.appUser = user
        }
    }

}
