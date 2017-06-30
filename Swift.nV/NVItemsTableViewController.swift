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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.appUser = delegate.appUser as User!
        NSLog("appUser for itemsTable is \(String(describing: self.appUser.email!))")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        appUser = delegate.appUser
        NSLog("Getting items for \(String(describing: appUser.email!))")
        
        let netStore : Bool = UserDefaults.standard.bool(forKey: "networkStorage")
        
        if (netStore && self.firstLoad) {
            let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let envs = NSDictionary(contentsOfFile: envPlist!)!
        
            let tURL = envs.value(forKey: "SecretsURL") as! String
            let secURL = URL(string: "\(tURL)/\(self.appUser.user_id)")
        
            #if DEBUG
                NSLog("Getting secrets \(String(describing: secURL))")
            #endif
        
            var request = URLRequest(url: secURL!)
            request.httpMethod = "GET"
            
            //_ = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    NSLog("DataTask error: " + error.localizedDescription)
                } else {
                    var success = true
                    var res: NSDictionary = [:]
                    do {
                        res = (try JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    } catch {
                        success = false
                    }
                    if (success) {
                        
                        let secrets: NSArray = res["secrets"] as! NSArray
                        var secret : NSDictionary!
                        for i in 0 ..< secrets.count {
                            secret = secrets[i] as! NSDictionary
                            let item_id : Int = secret["id"] as! Int
                            let item_checksum : String = secret["checksum"] as! String
                            let item_name : String = secret["name"] as! String
                            if !itemExists(item_id, checksum: item_checksum as NSString) {
                                NSLog("Adding \(item_name) to the db")
                                self.addItem(secret)
                            }
                        }
                        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = delegate.managedObjectContext!
                        
                        let fr = getItemsFetchRequest(self.appUser.email!)
                        
                        self.items = try! context.fetch(fr) as NSArray
                        
                        self.firstLoad = false
                        
                    }
                    self.data.setData(Data())
                    self.tableView.reloadData()
                }
                
            }).resume()
        }

        let fr = getItemsFetchRequest(self.appUser.email!)

        fr.returnsObjectsAsFaults = false
        
        self.items = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }
    
    /*func childrenFetchedResultsController (_ email:NSString,context:NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fr:NSFetchRequest<NSFetchRequestResult>
        if #available(iOS 10.0, OSX 10.12, *) {
            fr = Item.fetchRequest()
        } else {
            fr = NSFetchRequest(entityName: "Item")
        }
        
        fr.predicate = NSPredicate(format: "email LIKE '\(email)'", argumentArray: nil)
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil )
    }*/
    
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
        
        cell.detailTextLabel!.text = NSString(format: "%@",df.string(from: item.created! as Date)) as String
        //NSLog("built cell for \(item.name)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item : Item = self.items.object(at: indexPath.row) as! Item
        selectedItem = item
        NSLog("Selected item \(String(describing: item.name!))")
        self.performSegue(withIdentifier: "Edit Item", sender: self)
    }
    
    func addItem(_ secret: NSDictionary) {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let new_item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item
        
        new_item.name = secret["name"] as? String
        new_item.value = secret["contents"] as? String
        new_item.version = Int32(secret["version"] as! NSNumber)
        new_item.notes = secret["notes"] as? String
        new_item.email = appUser.email
        new_item.checksum = secret["checksum"] as? String
        new_item.item_id = Int32(secret["id"] as! NSNumber)
        new_item.created = Date() as NSDate
        
        do {
            try context.save()
        } catch let error as NSError {
            NSLog("Error saving context: %@", error)
        }
        
        
    }

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Edit Item") {
            let dv : NVEditItemViewController = segue.destination as! NVEditItemViewController
            dv.item = self.selectedItem!
            NSLog("edit item")
        }
    }
    

}
