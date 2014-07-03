//
//  NVRegisterViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 6/25/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVRegisterViewController: UIViewController {
    @IBOutlet var email : UITextField
    @IBOutlet var password1 : UITextField
    @IBOutlet var password2 : UITextField
    @IBOutlet var firstname : UITextField
    @IBOutlet var lastname : UITextField
    @IBOutlet var message : UILabel

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(sender : AnyObject) {
        if (self.email.text == "") ||
           (self.password1.text == "") ||
           (self.password2.text == "") ||
           (self.firstname.text == "") ||
            (self.lastname.text == "") {
                self.message.text = "all fields required"
        } else {
            self.message.text = "registering \(self.email.text)"
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext
            let entityD = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
            var user : User = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as User
            //Name("User",inManagedObjectContext: context) as NSManagedObject
            user.email = self.email.text
            if self.password1.text == self.password2.text {
                user.password = self.password1.text
            }
            user.firstname = self.firstname.text
            user.lastname = self.lastname.text
            
            var error:NSError? = nil
            context.save(&error)
            
            if error != nil {
                NSLog("%@",error!)
            }
            self.dismissModalViewControllerAnimated(true)
        }
    }

    @IBAction func cancel(sender : AnyObject) {
        self.dismissModalViewControllerAnimated(true)
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
