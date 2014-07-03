//
//  NVEditItemViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/2/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit

class NVEditItemViewController: UIViewController {

    @IBOutlet var nameField : UITextField
    @IBOutlet var valueField : UITextView
    @IBOutlet var notesField : UITextView
    @IBOutlet var createdLabel : UILabel
    
    var item : Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (item != nil) {
            nameField.text = item.name
            valueField.text = item.value
            notesField.text = item.notes
            var df : NSDateFormatter = NSDateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            
            createdLabel.text = NSString(format: "created %@",df.stringFromDate(item.created))
        } else {
            NSLog("NVEditItemViewController: Item is nil")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveItem(sender : AnyObject) {
        item.name = nameField.text
        item.value = valueField.text
        item.notes = notesField.text
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext
        var err :NSError?
        context.save(&err)
        if err != nil {
            NSLog("%@",err!)
        }
        self.clearform()
        self.dismissModalViewControllerAnimated(true)
    }
    
    @IBAction func deleteItem(sender : AnyObject) {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext
        
        var err :NSError?
        var alert : UIAlertController = UIAlertController(title: "Delete Item", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        var yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            NSLog("Delete item \(self.item.name)")
            self.clearform()
            context.deleteObject(self.item)
            context.save(&err)
            self.dismissModalViewControllerAnimated(true)
            })
        var noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancel(sender : AnyObject) {
        self.clearform()
        self.dismissModalViewControllerAnimated(true)
    }
    
    func clearform () {
        nameField.text = ""
        valueField.text=""
        notesField.text=""
        createdLabel.text=""
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
