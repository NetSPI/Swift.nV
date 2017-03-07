//
//  NVEditItemViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/2/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVEditItemViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var nameField : UITextField!
    @IBOutlet weak var valueField : UITextView!
    @IBOutlet weak var notesField : UITextView!
    @IBOutlet weak var createdLabel : UILabel!
    @IBOutlet weak var showButton : UIButton!
    @IBOutlet weak var editItemScroll: UIScrollView!
    
    var item : Item!
    var data = NSMutableData()

    var decryptedVal : NSString = ""
    var showValue:Bool = false
    var oldChecksum = ""
    
    var appUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (item != nil) {
            nameField.text = item.name
            self.decryptedVal = decryptString(item.value) as NSString
            self.oldChecksum = item.checksum
            valueField.text = String(repeating: "*",count: decryptedVal.length)
            notesField.text = item.notes
            let df : DateFormatter = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            
            createdLabel.text = NSString(format: "created %@",df.string(from: item.created as Date)) as String
        } else {
            NSLog("NVEditItemViewController: Item is nil")
        }

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editItemScroll.contentSize = CGSize(width: 320, height: 750)
    }

    //- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
    
    func textViewShouldBeginEditing(_ textView:UITextView) -> Bool {
        valueField.text = decryptedVal as String
        showValue = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView:UITextView) -> Bool {
        valueField.text = String(repeating: "*",count: decryptedVal.length)
        showValue = false
        return true
    }
    
    //- (void)textViewDidChange:(UITextView *)textView
    
    func textViewDidChange(_ textView:UITextView) {
        self.decryptedVal = valueField.text as NSString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveItem(_ sender : AnyObject) {
        item.name = nameField.text!
        if showValue {
            item.value = encryptString(valueField.text)
        } else {
            item.value = encryptString(decryptedVal as String)
        }
        
        item.notes = notesField.text
        item.checksum = generateChecksum(item)
        
        if item.checksum != self.oldChecksum {
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
            
            //var itvc : NVItemsTableViewController = self.parentViewController as NVItemsTableViewController
            //self.appUser = itvc.appUser
            
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
                NSLog("Error: %@", error.localizedDescription)
                j = nil
            }
            
            let tURL = envs.value(forKey: "UpdateSecretURL") as! String
            let upURL = "\(tURL)\(item.item_id)"
            let secURL = URL(string: upURL)
            
            NSLog("Updating secret for user with checksum: \(item.checksum)")
            
            let request = NSMutableURLRequest(url: secURL!)
            request.httpMethod = "PUT"
            request.httpBody = j
            
            _ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            
            self.saveContext()
            self.clearform()
            
        } else {
            self.saveContext()
            self.clearform()
            self.dismiss(animated: true, completion: nil)
        }
        

    }
    
    func saveContext() {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        var err :NSError?
        do {
            try context.save()
        } catch let error as NSError {
            err = error
        }
        if err != nil {
            NSLog("%@",err!)
        }
    }
    
    @IBAction func deleteItem(_ sender : AnyObject) {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let alert : UIAlertController = UIAlertController(title: "Delete Item", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction) in
            NSLog("Delete item \(self.item.name)")
            self.clearform()
            context.delete(self.item)
            do {
                try context.save()
            } catch let error as NSError {
                NSLog("Error: %@", error)
            } catch {
                fatalError()
            }
            self.dismiss(animated: true, completion: nil)

            })
        let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func copyValue(_ sender : AnyObject) {
        let pb :UIPasteboard = UIPasteboard.general
        pb.string = self.decryptedVal as String
    }
    
    func clearform () {
        nameField.text = ""
        valueField.text=""
        notesField.text=""
        createdLabel.text=""
    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(_ con: NSURLConnection!, didReceiveData _data:Data!) {
        //NSLog("didReceiveData")
        self.data.append(_data)
    }
    
    /* func connection(con: NSURLConnection!, didReceiveResponse _response:NSURLResponse!) {
    NSLog("didReceiveResponse")
    var response : NSHTTPURLResponse = _response
    
    }*/
    
    func connectionDidFinishLoading(_ con: NSURLConnection!) {
        
        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        
        if (res["id"] != nil) {
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            self.item.item_id = res["id"] as! NSNumber
            do {
                try context.save()
            } catch let error as NSError {
                NSLog("Error saving context: %@", error)
            }
            NSLog("Update Item \(self.item.item_id) in database")
        } else {
            self.data.setData(Data())
            NSLog("No ID on the response, strange")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        //self.message.text = "Connection to API failed"
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
