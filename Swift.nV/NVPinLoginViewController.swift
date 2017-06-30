//
//  NVPINLoginViewController.swift
//  swift.nV
//
//  Created by David Lindner on 4/18/17.
//  Copyright © 2017 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVPinLoginViewController: UIViewController {

    @IBOutlet weak var pin : UITextField!
    @IBOutlet weak var goButton : UIButton!
    @IBOutlet weak var message : UILabel!
    
    var appUser : User!

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
    
    @IBAction func go(_ sender: Any) {
        let defaults : UserDefaults = UserDefaults.standard
        
        let val = defaults.string(forKey: "PIN")
            
        if (val != nil && (self.pin.text == val!) ) {
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
            let em = defaults.string(forKey: "email")!
            fr.predicate = NSPredicate(format: "(email LIKE '\(em)')",argumentArray:  nil)
            
            let users : NSArray = try! context.fetch(fr) as NSArray

            if users.count > 0 {
                self.appUser = users[0] as! User
                self.performSegue(withIdentifier: "HomeView", sender: self)
            } else {
                NSLog("user \(String(describing: defaults.value(forKey: "email"))) does not exist, clearing use of PIN")
                defaults.set(false, forKey: "usePin")
                defaults.synchronize()
                self.message.text = "ERROR!"
            }
            
        } else {
            self.message.text = "INCORRECT PIN!!"
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "HomeView") {
            NSLog("passing \(String(describing: self.appUser.email!)) (\(String(describing: self.appUser.firstname!)) \(String(describing: self.appUser.lastname!)))")
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.appUser = self.appUser
        }

    }
    

}
