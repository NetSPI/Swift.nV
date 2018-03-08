//
//  ItemHelper.swift
//  Swift.nV
//
//  Created by Seth Law on 7/31/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import Foundation
import Security
import CoreData
import UIKit

func encryptString(_ toEncrypt: String) -> String {
    // Create Ciphertext
    let plainText = (toEncrypt as NSString).data(using: String.Encoding.utf8.rawValue)!
    let ret = plainText.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    
    NSLog("Encrypting \(toEncrypt) as \(String(describing: ret))")
    
    return ret
}

func decryptString(_ toDecrypt: String) -> String {
    // Create PlainText
    let cipherText = Data(base64Encoded: toDecrypt, options: NSData.Base64DecodingOptions(rawValue: 0))!
    let ret = String.init(data: cipherText, encoding: String.Encoding.utf8)
    
    NSLog("Decrypting \(toDecrypt) as \(ret!)")
    
    return ret!
}

func getCryptoKey() -> String {
    let envPlist = Bundle.main.path(forResource: "Environment", ofType: "plist")
    let envs = NSDictionary(contentsOfFile: envPlist!)!
    return envs.value(forKey: "CryptoKey") as! String
}

func generateChecksum(_ myItem: Item) -> String {
    let crypto: Crypto = Crypto()
    return crypto.sha256Hash(for: "\(String(describing: myItem.name))\(String(describing: myItem.value))\(String(describing: myItem.notes))")
}

func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

func getItemsFetchRequest(_ email: String) -> NSFetchRequest<NSFetchRequestResult> {
    let fr:NSFetchRequest<NSFetchRequestResult>
    if #available(iOS 10.0, OSX 10.12, *) {
        fr = Item.fetchRequest()
    } else {
        fr = NSFetchRequest(entityName: "Item")
    }
    
    if (email != "") {
        fr.predicate = NSPredicate(format: "email LIKE '\(email)'", argumentArray: nil)
    }
    return fr
}

func getItemByNameEmail(_ name: String,_ email: String) -> Item? {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    
    let fr:NSFetchRequest<NSFetchRequestResult>
    if #available(iOS 10.0, OSX 10.12, *) {
        fr = Item.fetchRequest()
    } else {
        fr = NSFetchRequest(entityName: "Item")
    }
    
    fr.predicate = NSPredicate(format: "(name LIKE '\(name)' AND email LIKE '\(email)') ", argumentArray: nil)
    let items: Array<Item> = try! context.fetch(fr) as! Array<Item>
    if items.count > 0 {
        return items[0]
    } else {
        return nil
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

func addItem(_ name: String,_ value: String,_ notes: String,_ email: String) -> Bool {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    var success = true
    
    let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item
    item.name = name
    item.value = encryptString(value)
    
    item.version = 1
    if notes == "notes" {
        item.notes = ""
    } else {
        item.notes = notes
    }
    item.created = Date() as NSDate
    item.email = email
    
    item.checksum = generateChecksum(item)
    
    do {
        try context.save()
    } catch let saveError as NSError {
        NSLog("Error saving context: %@", saveError)
        success = false
    }
    return success
}

func updateItemIdByNameEmail(_ name: String,_ email: String,_ item_id: Int32) -> Bool {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    var success = true
    
    let item : Item = getItemByNameEmail(name, email)!
    item.item_id = item_id
    
    do {
        try context.save()
    } catch let saveError as NSError {
        NSLog("Error saving context: %@", saveError)
        success = false
    }
    return success
}

func deleteItem(_ name: String?,_ email: String? ) -> Bool {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    var success = true
    
    if (name != nil && email != nil) {
        let item: Item? = getItemByNameEmail(name!, email!)
        context.delete(item!)
        
    } else if (email != nil) {
        let fr = getItemsFetchRequest(email!)
        let items: Array<Item> = try! context.fetch(fr) as! Array<Item>
        for i: Item in items {
            context.delete(i)
        }
    } else {
        let fr = getItemsFetchRequest("")
        let items: Array<Item> = try! context.fetch(fr) as! Array<Item>
        for i: Item in items {
            context.delete(i)
        }
    }
    
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
