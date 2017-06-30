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
    var email : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.message.text = "loading"
        let defaults : UserDefaults = UserDefaults.standard
        if defaults.object(forKey: "loggedin") != nil {
            self.email = defaults.string(forKey: "email")
            if (self.email == nil) {
                NSLog("email is blank")
            } else {
                NSLog("Saved email is '\(email!)'")
            }
        } else {
                NSLog("no preferences, setting up")
                setupPreferences(defaults)
                setupDefaultAccounts()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.go()
    }
    
    func setupDefaultAccounts() {
        _ = registerUser("test@test.com","test","Test","User",nil,nil)
        _ = addItem("Active Directory (testAD)", "mys3cr3tv4lu3!", "For corporate user only", "test@test.com")
        _ = addItem("Gmail - test@test.com", "123456", "Personal email account", "test@test.com")
        _ = addItem("HBO Access Key", "31337Pass", "Login: test+hbo@test.com", "test@test.com")
        _ = registerUser("test2@test.com","test2","Second","User",nil,nil)
        _ = addItem("Yahoo Login", "password1", "Login: test2@yahoo.com", "test2@test.com")
        _ = addItem("Facebook (second.user)", "password1", "Login: second.user", "test2@test.com")
    }
    
    func setupPreferences(_ defaults: UserDefaults) {
        defaults.set("", forKey: "email")
        defaults.set(false, forKey: "loggedin")
        defaults.set(false, forKey: "networkStorage")
        defaults.set(false, forKey: "usePin")
        defaults.set("1111", forKey: "PIN")

        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func go() {
        let defaults : UserDefaults = UserDefaults.standard
        
        if ( defaults.bool(forKey: "usePin") ) {
            self.performSegue(withIdentifier: "PinView", sender: self)
        } else {
            
            self.email = defaults.string(forKey: "email")
            
            if ( self.email != nil ) {
                NSLog("Logged in email is \(self.email!)")
            } else {
                NSLog("Not currently logged in")
            }
            let loggedin :Bool = defaults.bool(forKey: "loggedin")
        
            if self.email == nil || !loggedin {
                self.performSegue(withIdentifier: "InitLogin", sender: self)
            } else {
                self.performSegue(withIdentifier: "InitHome", sender: self)
            }
        }
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "InitHome") {
            
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest<NSFetchRequestResult>
            if #available(iOS 10.0, OSX 10.12, *) {
                fr = User.fetchRequest()
            } else {
                fr = NSFetchRequest(entityName: "User")
            }
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "email LIKE '\(self.email!)'", argumentArray: nil)
            
            let users : NSArray = try! context.fetch(fr) as NSArray
            
            let user : User = users[0] as! User
            
            NSLog("passing \(String(describing: user.email!)) (\(String(describing: user.firstname!)) \(String(describing: user.lastname!)))")
            delegate.appUser = user
        }
    }

}
