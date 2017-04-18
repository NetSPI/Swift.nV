//
//  Item.swift
//  Swift.nV
//
//  Created by Seth Law on 7/1/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import CoreData

@objc(Item)
class Item: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var value: String
    @NSManaged var notes: String
    @NSManaged var email: String
    @NSManaged var created: Date
    @NSManaged var version: NSNumber
    @NSManaged var checksum: String
    @NSManaged var item_id: NSNumber
}

