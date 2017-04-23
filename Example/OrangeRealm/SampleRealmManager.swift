//
//  SampleRealmManager.swift
//  OrangeRealm
//
//  Created by pisces on 24/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RealmSwift
import OrangeRealm

class SampleRealmManager: AbstractRealmManager {

    // MARK: - Overridden: AbstractRealmManager
    
    override class var shared: AbstractRealmManager {
        struct Static {
            static let instance = SampleRealmManager()
        }
        return Static.instance
    }
    
    override var schemaVersion: UInt64 {
        return 1
    }
    
    override var fileURL: URL {
        return URL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)/sample.realm", isDirectory: false)
    }
    
    override var objectTypes: [Object.Type]? {
        return [SampleObject.self]
    }
    
    override func deleteAll(_ realm: Realm) {
        realm.deleteAll()
    }
    
    override func process(forMigration migration: Migration, oldSchemaVersion: UInt64) {
    }
}
