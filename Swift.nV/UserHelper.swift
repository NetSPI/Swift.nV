//
//  UserHelper.swift
//  swift.nV
//
//  Created by Seth Law on 5/1/17.
//  Copyright © 2017 nVisium. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func registerUser(_ email: String,_ password: String,_ firstname: String,_ lastname: String,_ token: String?,_ user_id: Int32?) -> User? {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    
    let user : User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
    
    user.email = email
    user.password = password
    user.firstname = firstname
    user.lastname = lastname
    if token != nil {
        user.token = token!
    }
    if user_id != nil {
        user.user_id = user_id!
    }
    
    do {
        try context.save()
    } catch let error as NSError {
        NSLog("Error saving context: %@", error)
        return nil
    }
    
    return user
}

func getUser(_ email:String) -> User? {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    
    //let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
    let fr:NSFetchRequest<NSFetchRequestResult>
    if #available(iOS 10.0, OSX 10.12, *) {
        fr = User.fetchRequest()
    } else {
        fr = NSFetchRequest(entityName: "User")
    }
    //let fr:NSFetchRequest<NSFetchRequestResult = User.FetchRequest(entityName:"User")
    fr.returnsObjectsAsFaults = false
    fr.predicate = NSPredicate(format: "(email LIKE '\(email)')",argumentArray:  nil)
    
    let users : Array<User> = try! context.fetch(fr) as! Array<User>
    if users.count > 0 {
        return users[0]
    } else {
        return nil
    }
}

func getPIN() -> String? {
    return UserDefaults.standard.string(forKey: "PIN")
}

func authenticateUser(_ email:String,_ password:String) -> User? {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    let defaults : UserDefaults = UserDefaults.standard
    
    //let fr:NSFetchRequest = NSFetchRequest(entityName:"User")
    let fr:NSFetchRequest<NSFetchRequestResult>
    if #available(iOS 10.0, OSX 10.12, *) {
        fr = User.fetchRequest()
    } else {
        fr = NSFetchRequest(entityName: "User")
    }
    //let fr:NSFetchRequest<NSFetchRequestResult = User.FetchRequest(entityName:"User")
    fr.returnsObjectsAsFaults = false
    fr.predicate = NSPredicate(format: "(email LIKE '\(email)' AND password LIKE '\(password)')",argumentArray:  nil)
    
    let users : Array<User> = try! context.fetch(fr) as! Array<User>
    if users.count > 0 {
        defaults.set(users[0].email! as NSString, forKey: "email")
        defaults.set(true, forKey: "loggedin")
        defaults.synchronize()
        NSLog("Setting email key in NSUserDefaults to \(String(describing: users[0].email!))")
        
        return users[0]
    } else {
        return nil
    }
}

func deleteUser(_ email: String?) -> Bool {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    let defaults : UserDefaults = UserDefaults.standard
    var success = true
    
    let fr:NSFetchRequest<NSFetchRequestResult>
    if #available(iOS 10.0, OSX 10.12, *) {
        fr = User.fetchRequest()
    } else {
        fr = NSFetchRequest(entityName: "User")
    }
    
    if (email != nil) {
        fr.predicate = NSPredicate(format: "email LIKE '\(email!)'", argumentArray: nil)
    }
    
    let users :Array<User> = try! context.fetch(fr) as! Array<User>
    
    for u: User in users {
        _ = deleteItem(nil, u.email!)
        context.delete(u)
    }
    
    defaults.removeObject(forKey: "email")
    defaults.removeObject(forKey: "loggedin")
    defaults.removeObject(forKey: "networkStorage")
    defaults.removeObject(forKey: "usePin")
    defaults.removeObject(forKey: "PIN")
    
    do {
        try context.save()
    } catch let error as NSError {
        NSLog("Error: %@", error)
        success = false
    } catch {
        fatalError()
    }
    
    return success
}
