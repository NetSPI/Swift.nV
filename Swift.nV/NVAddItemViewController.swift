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
    
    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var valueField : UITextView!
    @IBOutlet weak var notesField : UITextView!
    @IBOutlet weak var message : UILabel!
    @IBOutlet weak var addItemScroll: UIScrollView!
    
    var item : Item!
    var appUser : User!
    var data = NSMutableData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nameField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addItemScroll.contentSize = CGSizeMake(320, 750)
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
            let envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            
            let hvc : NVHomeViewController = self.parentViewController as! NVHomeViewController
            self.appUser = hvc.appUser
            NSLog("Storing \(self.nameField.text) for \(appUser.email)")
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: context) as! Item
            item.name = self.nameField.text!
            item.value = encryptString(self.valueField.text)
            
            item.version = 1
            if self.notesField.text == "notes" {
                item.notes = ""
            } else {
                item.notes = self.notesField.text
            }
            item.created = NSDate()
            item.email = appUser.email
            
            item.checksum = generateChecksum(item)
            
            let secret = [
                "name": item.name,
                "contents": item.value,
                "checksum": item.checksum,
                "version": item.version,
                "notes": item.notes,
                "user_id": self.appUser.user_id
            ]
            
            var j: NSData?
            do {
                j = try NSJSONSerialization.dataWithJSONObject(secret, options: NSJSONWritingOptions.PrettyPrinted)
            } catch let error as NSError {
                NSLog("Error: %@", error)
                j = nil
            }
            
            //NSLog("Adding \(item.name) to keychain")
            //saveToKeychain(item.name, data: encryptString(self.valueField.text))
            
            let tURL = envs.valueForKey("NewSecretURL") as! String
            let secURL = NSURL(string: tURL)
            
            //NSLog("Adding secret \(j) for user (\(self.appUser.user_id)) with checksum: \(item.checksum)")
            
            let request = NSMutableURLRequest(URL: secURL!)
            request.HTTPMethod = "POST"
            request.HTTPBody = j
            
            _ = NSURLConnection(request: request, delegate: self, startImmediately: true)
        }
    }
    
    func resetForm() {
        self.nameField.text = ""
        self.valueField.text = ""
        self.notesField.text = ""
        self.message.text = ""
    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        let res : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
        if (res["id"] != nil) {
            self.message.text = "success"
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext
            self.item.item_id = res["id"] as! NSNumber
            do {
                try context!.save()
            } catch let saveError as NSError {
                NSLog("Error saving context: %@", saveError)
                self.message.text = "Error saving data.";
                return;
            }
            
            let alert : UIAlertController = UIAlertController(title: "Item Added", message: "Add another item?", preferredStyle: UIAlertControllerStyle.Alert)
            let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction) in
                self.resetForm()
                self.data.setData(NSData())
                self.nameField.becomeFirstResponder()
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction) in
                NSLog("No")
                self.resetForm()
                self.tabBarController?.selectedIndex = 0
                //self.tabBarController.selectedIndex = 0
            })
            
            alert.addAction(yesItem)
            alert.addAction(noItem)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            self.data.setData(NSData())
            self.nameField.becomeFirstResponder()
            self.message.text = "error"
        }
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.message.text = "Connection to API failed"
        NSLog("%@",error!)
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
