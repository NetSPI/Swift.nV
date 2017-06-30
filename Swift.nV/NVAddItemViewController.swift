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
    var success : Bool = true
    var data = NSMutableData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.becomeFirstResponder()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.appUser = delegate.appUser
        
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
    
    @IBAction func cancel() {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func save(_ sender : AnyObject) {
        if self.nameField.text == "" {
            self.message.text = "name required"
        } else if self.valueField.text == "" {
            self.message.text = "value required"
        } else {
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            
            NSLog("Storing \(String(describing: self.nameField.text)) for \(String(describing: appUser.email))")
            
            success = addItem(self.nameField.text!, self.valueField.text!, self.notesField.text! , appUser.email!)

            let defaults : UserDefaults = UserDefaults.standard
            
            if ( defaults.bool(forKey: "networkStorage") ) {
                let secret = [
                    "name": item.name as Any,
                    "contents": item.value as Any,
                    "checksum": item.checksum as Any,
                    "version": item.version,
                    "notes": item.notes as Any,
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
            
                var request = URLRequest(url: secURL!)
                request.httpMethod = "POST"
                request.httpBody = j
            
                //_ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
                
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    
                    if let error = error {
                        NSLog("DataTask error: " + error.localizedDescription)
                    } else {
                        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                        
                        if (res["id"] != nil) {
                            self.message.text = "success"
                            self.success = updateItemIdByNameEmail(self.item.name!, self.item.email!, Int32(res["id"] as! NSNumber))
                            self.addAnotherItem()
                            
                        } else {
                            self.data.setData(Data())
                            self.nameField.becomeFirstResponder()
                            self.message.text = "error"
                        }
                    }
                    
                }).resume()
            } else {
                if (success) {
                    self.message.text = "success"
                    addAnotherItem()
                }
            }
        }
    }
    
    func addAnotherItem() {
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
        })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetForm() {
        self.nameField.text = ""
        self.valueField.text = ""
        self.notesField.text = ""
        self.message.text = ""
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
