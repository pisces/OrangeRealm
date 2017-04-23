//
//  SampleObject.swift
//  OrangeRealm
//
//  Created by pisces on 24/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RealmSwift

class SampleObject: Object {
    dynamic var name: String?
    dynamic var id: Int = 0
    
    convenience init(id: Int, name: String?) {
        self.init()
        
        self.id = id
        self.name = name
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
