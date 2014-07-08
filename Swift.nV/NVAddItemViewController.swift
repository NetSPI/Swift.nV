//
//  NVAddItemViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVAddItemViewController: UIViewController {

    @IBOutlet var nameField : UITextField
    @IBOutlet var valueField : UITextView
    @IBOutlet var notesField : UITextView
    @IBOutlet var message : UILabel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender : AnyObject) {
        if self.nameField.text == "" {
            self.message.text = "name required"
        } else if self.valueField.text == "" {
            self.message.text = "value required"
        } else {
            var hvc : NVHomeViewController = self.parentViewController as NVHomeViewController
            var appUser : User = hvc.appUser
            NSLog("Storing \(self.nameField.text) for \(appUser.email)")
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext
            let entityD = NSEntityDescription.entityForName("Item", inManagedObjectContext: context)
            
            var item : Item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: context) as Item
            item.name = self.nameField.text
            item.value = self.valueField.text
            if self.notesField.text == "notes" {
                item.notes = ""
            } else {
                item.notes = self.notesField.text
            }
            item.created = NSDate()
            item.email = appUser.email
            
            var error : NSError? = nil
            context.save(&error)
            
            if error != nil {
                NSLog("%@",error!)
            } else {
                var alert : UIAlertController = UIAlertController(title: "Item Added", message: "Add another item?", preferredStyle: UIAlertControllerStyle.Alert)
                var yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
                        (action:UIAlertAction!) in
                        self.resetForm()
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    })
                var noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
                        (action:UIAlertAction!) in
                        NSLog("No")
                        self.resetForm()
                        self.tabBarController.selectedIndex = 0
                    })

                alert.addAction(yesItem)
                alert.addAction(noItem)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                /* UIAlertView alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this.  This action cannot be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
                [alert show]; */
            }
        }
    }
    
    func resetForm() {
        self.nameField.text = ""
        self.valueField.text = ""
        self.notesField.text = ""
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
