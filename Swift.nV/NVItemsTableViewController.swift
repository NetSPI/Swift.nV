//
//  NVItemsTableViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/2/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVItemsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items:NSArray = []
    var selectedItem:Item?

    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //let iv : UIImageView = UIImageView(image: UIImage(contentsOfFile: "logo-color.png"))
        //self.tableView.backgroundView = iv
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context = delegate.managedObjectContext
        var hvc : NVHomeViewController = self.parentViewController as NVHomeViewController
        var appUser : User = hvc.appUser
        NSLog("Getting items for \(appUser.email)")
        
        //let frc = self.childrenFetchedResultsController(appUser.email, context: context)
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Item")
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "email LIKE '\(appUser.email)'", nil)
        
        var err:NSError? = nil
        self.items = context.executeFetchRequest(fr, error: &err)
        NSLog("Items: \(self.items)")
        
        self.tableView.reloadData()
    }
    
    func childrenFetchedResultsController (email:NSString,context:NSManagedObjectContext) -> NSFetchedResultsController {
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Item")
        fr.predicate = NSPredicate(format: "email LIKE '\(email)'", nil)
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil )
    }
    
    override func numberOfSectionsInTableView (tableView:UITableView) -> NSInteger {
        return 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // #pragma mark - Table view data source
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        //NSLog("have \(self.items.count) items to display")
        return self.items.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        var item : Item = self.items.objectAtIndex(indexPath.row) as Item
        cell.textLabel.text = item.name
        var df : NSDateFormatter = NSDateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        
        cell.detailTextLabel.text = NSString(format: "created %@",df.stringFromDate(item.created))
        //NSLog("built cell for \(item.name)")
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var item : Item = self.items.objectAtIndex(indexPath.row) as Item
        selectedItem = item
        NSLog("Selected item \(item.name)")
        self.performSegueWithIdentifier("Edit Item", sender: self)
    }
    
    /*
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject?) {
        if (segue.identifier == "Edit Item") {
            var dv : NVEditItemViewController = segue.destinationViewController as NVEditItemViewController
            dv.item = self.selectedItem!
            NSLog("edit item")
        }
    }
    

}
