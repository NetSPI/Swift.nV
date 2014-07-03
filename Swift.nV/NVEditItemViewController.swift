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
    }
    
    @IBAction func deleteItem(sender : AnyObject) {
    }
    
    @IBAction func cancel(sender : AnyObject) {
        self.dismissModalViewControllerAnimated(true)
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
