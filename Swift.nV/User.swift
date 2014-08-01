//
//  User.swift
//  Swift.nV
//
//  Created by Seth Law on 6/27/14.
//  Copyright (c) 2014 nVisium. All rights reserved.
//

import CoreData

@objc(User)
class User: NSManagedObject {
    @NSManaged var email: String
    @NSManaged var password: String
    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var user_id: NSNumber
    @NSManaged var token: String
}
