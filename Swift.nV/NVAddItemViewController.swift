//
//  NVAddItemViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class NVAddItemViewController: UIViewController {

    @IBOutlet var nameField : UITextField!
    @IBOutlet var valueField : UITextView!
    @IBOutlet var notesField : UITextView!
    @IBOutlet var message : UILabel!
    
    var item : Item!
    var data = NSMutableData()
    
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
            var envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
            var envs = NSDictionary(contentsOfFile: envPlist)
            
            var hvc : NVHomeViewController = self.parentViewController as NVHomeViewController
            var appUser : User = hvc.appUser
            NSLog("Storing \(self.nameField.text) for \(appUser.email)")
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext
            let entityD = NSEntityDescription.entityForName("Item", inManagedObjectContext: context)
            
            item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: context) as Item
            item.name = self.nameField.text
            item.value = encryptString(self.valueField.text)
            
            var crypto: Crypto = Crypto()
            
            // Create Checksum
            item.checksum = crypto.sha256HashFor(item.value)
            
            item.version = 1
            if self.notesField.text == "notes" {
                item.notes = ""
            } else {
                item.notes = self.notesField.text
            }
            item.created = NSDate()
            item.email = appUser.email
            
            var secret = [
                "name": item.name,
                "contents": item.value,
                "checksum": item.checksum,
                "version": item.version,
                "notes": item.notes,
            ]
            
            var err:NSError? = nil
            var j = NSJSONSerialization.dataWithJSONObject(secret, options: NSJSONWritingOptions.PrettyPrinted, error: &err)
            
            var tURL = envs.valueForKey("NewSecretURL") as String
            var secURL = NSURL(string: tURL)
            
            NSLog("Adding secret for user with checksum: \(item.checksum)")
            
            var request = NSMutableURLRequest(URL: secURL)
            request.HTTPMethod = "POST"
            request.HTTPBody = j
            
            var queue = NSOperationQueue()
            var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
            
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
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    /* func connection(con: NSURLConnection!, didReceiveResponse _response:NSURLResponse!) {
    NSLog("didReceiveResponse")
    var response : NSHTTPURLResponse = _response
    
    }*/
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        NSLog("connectionDidFinishLoading")
        var resStr = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        NSLog("response: \(resStr)")
        
        var res : NSDictionary = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if res["id"] {
            self.message.text = "success"
            self.dismissViewControllerAnimated(true, completion: nil)
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext
            self.item.item_id = res["id"] as NSNumber
            var error : NSError? = nil
            context.save(&error)
            
        } else {
            self.message.text = "error"
        }
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
