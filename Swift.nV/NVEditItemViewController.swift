//
//  NVEditItemViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/2/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVEditItemViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var nameField : UITextField!
    @IBOutlet var valueField : UITextView!
    @IBOutlet var notesField : UITextView!
    @IBOutlet var createdLabel : UILabel!
    @IBOutlet var showButton : UIButton!
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
            self.decryptedVal = decryptString(item.value)
            self.oldChecksum = item.checksum
            valueField.text = String(count:decryptedVal.length,repeatedValue:"*" as Character)
            notesField.text = item.notes
            var df : NSDateFormatter = NSDateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            
            createdLabel.text = NSString(format: "created %@",df.stringFromDate(item.created))
        } else {
            NSLog("NVEditItemViewController: Item is nil")
        }

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editItemScroll.contentSize = CGSizeMake(320, 750)
    }

    //- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
    
    func textViewShouldBeginEditing(textView:UITextView) -> Bool {
        valueField.text = decryptedVal
        showValue = true
        return true
    }
    
    func textViewShouldEndEditing(textView:UITextView) -> Bool {
        valueField.text = String(count:decryptedVal.length,repeatedValue:"*" as Character)
        showValue = false
        return true
    }
    
    //- (void)textViewDidChange:(UITextView *)textView
    
    func textViewDidChange(textView:UITextView) {
        self.decryptedVal = valueField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveItem(sender : AnyObject) {
        item.name = nameField.text
        if showValue {
            item.value = encryptString(valueField.text)
        } else {
            item.value = encryptString(decryptedVal)
        }
        
        var crypto: Crypto = Crypto()
        item.notes = notesField.text
        item.checksum = generateChecksum(item)
        
        if item.checksum != self.oldChecksum {
            var envPlist = NSBundle.mainBundle().pathForResource("Environment", ofType: "plist")
            var envs = NSDictionary(contentsOfFile: envPlist!)
            
            //var itvc : NVItemsTableViewController = self.parentViewController as NVItemsTableViewController
            //self.appUser = itvc.appUser
            
            var secret = [
                "name": item.name,
                "contents": item.value,
                "checksum": item.checksum,
                "version": item.version,
                "notes": item.notes,
                "user_id": self.appUser.user_id
            ]
            
            var err:NSError? = nil
            var j = NSJSONSerialization.dataWithJSONObject(secret, options: NSJSONWritingOptions.PrettyPrinted, error: &err)
            
            var tURL = envs.valueForKey("UpdateSecretURL") as String
            var upURL = "\(tURL)\(item.item_id)"
            var secURL = NSURL(string: upURL)
            
            NSLog("Updating secret for user with checksum: \(item.checksum)")
            
            var request = NSMutableURLRequest(URL: secURL)
            request.HTTPMethod = "PUT"
            request.HTTPBody = j
            
            var queue = NSOperationQueue()
            var con = NSURLConnection(request: request, delegate: self, startImmediately: true)
            
            self.saveContext()
            self.clearform()
            
        } else {
            self.saveContext()
            self.clearform()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        

    }
    
    func saveContext() {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext!
        var err :NSError?
        context.save(&err)
        if err != nil {
            NSLog("%@",err!)
        }
    }
    
    @IBAction func deleteItem(sender : AnyObject) {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext!
        
        var err :NSError?
        var alert : UIAlertController = UIAlertController(title: "Delete Item", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        var yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            NSLog("Delete item \(self.item.name)")
            self.clearform()
            context.deleteObject(self.item)
            context.save(&err)
            self.dismissViewControllerAnimated(true, completion: nil)

            })
        var noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func copyValue(sender : AnyObject) {
        var pb :UIPasteboard = UIPasteboard.generalPasteboard()
        pb.string = self.decryptedVal
    }
    
    func clearform () {
        nameField.text = ""
        valueField.text=""
        notesField.text=""
        createdLabel.text=""
    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(con: NSURLConnection!, didReceiveData _data:NSData!) {
        //NSLog("didReceiveData")
        self.data.appendData(_data)
    }
    
    /* func connection(con: NSURLConnection!, didReceiveResponse _response:NSURLResponse!) {
    NSLog("didReceiveResponse")
    var response : NSHTTPURLResponse = _response
    
    }*/
    
    func connectionDidFinishLoading(con: NSURLConnection!) {
        //NSLog("connectionDidFinishLoading")
        var resStr = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        //NSLog("response: \(resStr)")
        
        var res : NSDictionary = NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if (res["id"] != nil) {
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context = delegate.managedObjectContext!
            self.item.item_id = res["id"] as NSNumber
            var error : NSError? = nil
            context.save(&error)
            NSLog("Update Item \(self.item.item_id) in database")
        } else {
            self.data.setData(NSData())
            NSLog("No ID on the response, strange")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
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
