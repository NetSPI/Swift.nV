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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nameField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addItemScroll.contentSize = CGSize(width: 320, height: 750)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender : AnyObject) {
        if self.nameField.text == "" {
            self.message.text = "name required"
        } else if self.valueField.text == "" {
            self.message.text = "value required"
        } else {
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            
            let hvc : NVHomeViewController = self.parent as! NVHomeViewController
            self.appUser = hvc.appUser
            NSLog("Storing \(self.nameField.text) for \(appUser.email)")
            
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item
            item.name = self.nameField.text!
            item.value = encryptString(self.valueField.text)
            
            item.version = 1
            if self.notesField.text == "notes" {
                item.notes = ""
            } else {
                item.notes = self.notesField.text
            }
            item.created = Date()
            item.email = appUser.email
            
            item.checksum = generateChecksum(item)
            
            let secret = [
                "name": item.name,
                "contents": item.value,
                "checksum": item.checksum,
                "version": item.version,
                "notes": item.notes,
                "user_id": self.appUser.user_id
            ] as [String : Any]
            
            var j: Data?
            do {
                j = try JSONSerialization.data(withJSONObject: secret, options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch let error as NSError {
                NSLog("Error: %@", error)
                j = nil
            }
            
            //NSLog("Adding \(item.name) to keychain")
            //saveToKeychain(item.name, data: encryptString(self.valueField.text))
            
            let tURL = envs.value(forKey: "NewSecretURL") as! String
            let secURL = URL(string: tURL)
            
            //NSLog("Adding secret \(j) for user (\(self.appUser.user_id)) with checksum: \(item.checksum)")
            
            let request = NSMutableURLRequest(url: secURL!)
            request.httpMethod = "POST"
            request.httpBody = j
            
            _ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
        }
    }
    
    func resetForm() {
        self.nameField.text = ""
        self.valueField.text = ""
        self.notesField.text = ""
        self.message.text = ""
    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(_ con: NSURLConnection!, didReceiveData _data:Data!) {
        //NSLog("didReceiveData")
        self.data.append(_data)
    }
    
    func connectionDidFinishLoading(_ con: NSURLConnection!) {
        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        
        if (res["id"] != nil) {
            self.message.text = "success"
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext
            self.item.item_id = res["id"] as! NSNumber
            do {
                try context!.save()
            } catch let saveError as NSError {
                NSLog("Error saving context: %@", saveError)
                self.message.text = "Error saving data.";
                return;
            }
            
            let alert : UIAlertController = UIAlertController(title: "Item Added", message: "Add another item?", preferredStyle: UIAlertControllerStyle.alert)
            let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
                (action:UIAlertAction) in
                self.resetForm()
                self.data.setData(Data())
                self.nameField.becomeFirstResponder()
                alert.dismiss(animated: true, completion: nil)
            })
            let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
                (action:UIAlertAction) in
                NSLog("No")
                self.resetForm()
                self.tabBarController?.selectedIndex = 0
                //self.tabBarController.selectedIndex = 0
            })
            
            alert.addAction(yesItem)
            alert.addAction(noItem)
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.data.setData(Data())
            self.nameField.becomeFirstResponder()
            self.message.text = "error"
        }
    }
    
    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
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
