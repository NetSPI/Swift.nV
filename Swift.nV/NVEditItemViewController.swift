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
    
    var item : Item!
    var showValue:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (item != nil) {
            nameField.text = item.name
            var val:NSString = item.value
            valueField.text = String(count:val.length,repeatedValue:"*" as Character)
            notesField.text = item.notes
            var df : NSDateFormatter = NSDateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            
            createdLabel.text = NSString(format: "created %@",df.stringFromDate(item.created))
        } else {
            NSLog("NVEditItemViewController: Item is nil")
        }

        // Do any additional setup after loading the view.
    }

    //- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
    
    func textViewShouldBeginEditing(textView:UITextView) -> Bool {
        valueField.text = item.value
        showValue = true
        return true
    }
    
    func textViewShouldEndEditing(textView:UITextView) -> Bool {
        var val:NSString = item.value
        valueField.text = String(count:val.length,repeatedValue:"*" as Character)
        showValue = false
        return true
    }
    
    //- (void)textViewDidChange:(UITextView *)textView
    
    func textViewDidChange(textView:UITextView) {
        item.value = valueField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveItem(sender : AnyObject) {
        item.name = nameField.text
        if showValue {
            item.value = valueField.text
        }
        item.notes = notesField.text
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext
        var err :NSError?
        context.save(&err)
        if err != nil {
            NSLog("%@",err!)
        }
        self.clearform()
        self.dismissViewControllerAnimated(true, completion: nil)
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
        if showValue {
            pb.string = valueField.text
        } else {
            pb.string = item.value
        }
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
