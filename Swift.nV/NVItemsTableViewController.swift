//
//  NVItemsTableViewController.swift
//  Swift.nV
//
//  Created by Seth Law on 7/2/14.
//  Copyright (c) 2016 nVisium. All rights reserved.
//

import UIKit
import CoreData

class NVItemsTableViewController: UITableViewController {
    
    var items:NSArray = []
    var selectedItem:Item?
    
    var appUser : User!
    var data = NSMutableData()
    var firstLoad = true

    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let hvc : NVHomeViewController = self.parent as! NVHomeViewController
        
        self.appUser = hvc.appUser as User!
        NSLog("appUser for itemsTable is \(self.appUser.email) (\(self.appUser.user_id))")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //let iv : UIImageView = UIImageView(image: UIImage(contentsOfFile: "logo-color.png"))
        //self.tableView.backgroundView = iv
        //self.tableView.contentInset(22,0,0,0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let hvc : NVHomeViewController = self.parent as! NVHomeViewController
        appUser = hvc.appUser
        NSLog("Getting items for \(appUser.email)")
        
        let netStore : Bool = UserDefaults.standard.bool(forKey: "networkStorage")
        
        if (netStore && self.firstLoad) {
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
        
            let tURL = envs.value(forKey: "SecretsURL") as! String
            let secURL = URL(string: "\(tURL)/\(self.appUser.user_id)")
        
            NSLog("Getting secrets \(secURL)")
        
            let request = NSMutableURLRequest(url: secURL!)
            request.httpMethod = "GET"
            
            _ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
        }
        // let request:NSFetchRequest<NSFetchRequestResult> = UnsyncedTask.fetchRequest()

        let fr:NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, OSX 10.12, *) {
            fr = Item.fetchRequest()
        } else {
            fr = NSFetchRequest(entityName: "Item")
        }

        fr.returnsObjectsAsFaults = false
        
        self.items = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }
    
    func childrenFetchedResultsController (_ email:NSString,context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fr:NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, OSX 10.12, *) {
            fr = Item.fetchRequest()
        } else {
            fr = NSFetchRequest(entityName: "Item")
        }
        
        fr.predicate = NSPredicate(format: "email LIKE '\(email)'", argumentArray: nil)
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil )
    }
    
    override func numberOfSections (in tableView:UITableView) -> NSInteger {
        return 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // #pragma mark - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //NSLog("have \(self.items.count) items to display")
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        let item : Item = self.items.object(at: indexPath.row) as! Item
        cell.textLabel!.text = item.name
        let df : DateFormatter = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        
        cell.detailTextLabel!.text = NSString(format: "%@",df.string(from: item.created as Date)) as String
        //NSLog("built cell for \(item.name)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item : Item = self.items.object(at: indexPath.row) as! Item
        selectedItem = item
        NSLog("Selected item \(item.name)")
        self.performSegue(withIdentifier: "Edit Item", sender: self)
    }
    
    // NSURLConnectionDataDelegate Classes
    
    func connection(_ con: NSURLConnection!, didReceiveData _data:Data!) {
        //NSLog("didReceiveData")
        self.data.append(_data)
    }
    
    func connectionDidFinishLoading(_ con: NSURLConnection!) {
        
        let res : NSDictionary = (try! JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        if ((res["secrets"]) != nil) {
            
            let secrets: NSArray = res["secrets"] as! NSArray
            var secret : NSDictionary!
            for i in 0 ..< secrets.count {
                secret = secrets[i] as! NSDictionary
                let item_id : Int = secret["id"] as! Int
                let item_checksum : String = secret["checksum"] as! String
                let item_name : String = secret["name"] as! String
                if !self.itemExists(item_id, checksum: item_checksum as NSString) {
                    NSLog("Adding \(item_name) to the db")
                    self.addItem(secret)
                }
            }
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest<NSFetchRequestResult>
            if #available(iOS 10.0, OSX 10.12, *) {
                fr = Item.fetchRequest()
            } else {
                fr = NSFetchRequest(entityName: "Item")
            }
            
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "email LIKE '\(appUser.email)'", argumentArray: nil)
            
            self.items = try! context.fetch(fr) as NSArray
            
            self.firstLoad = false
            self.tableView.reloadData()
        
        }
        self.data.setData(Data())
        
    }
    
    func connection(_ connection: NSURLConnection!, didFailWithError error: NSError!) {
        NSLog("%@",error!)
    }
    
    func addItem(_ secret: NSDictionary) {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let new_item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item
        
        new_item.name = secret["name"] as! String
        new_item.value = secret["contents"] as! String
        new_item.version = secret["version"] as! NSNumber
        new_item.notes = secret["notes"] as! String
        new_item.email = appUser.email
        new_item.checksum = secret["checksum"] as! String
        new_item.item_id = secret["id"] as! NSNumber
        new_item.created = Date()
        
        do {
            try context.save()
        } catch let error as NSError {
            NSLog("Error saving context: %@", error)
        }
        
        
    }
    
    func itemExists(_ item_id: Int, checksum: NSString) -> Bool {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, OSX 10.12, *) {
            fr = Item.fetchRequest()
        } else {
            fr = NSFetchRequest(entityName: "Item")
        }
        
        fr.predicate = NSPredicate(format: "item_id = \(item_id) AND checksum = '\(checksum)'", argumentArray: nil)
        let items: NSArray = try! context.fetch(fr) as NSArray
        
        if (items.count > 0) {
            return true
        } else {
            return false
        }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Edit Item") {
            let dv : NVEditItemViewController = segue.destination as! NVEditItemViewController
            dv.item = self.selectedItem!
            dv.appUser = self.appUser
            NSLog("edit item")
        }
    }
    

}
