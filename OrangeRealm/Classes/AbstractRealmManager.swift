//
//  AbstractRealmManager.swift
//  OrangeRealm
//
//  Created by Steve Kim on 23/4/17.
//

import Realm
import RealmSwift

open class AbstractRealmManager {
    
    // MARK: - Constants
    
    public static let queue = DispatchQueue(label: Const.name)
    public let notificationManager = RealmNotificationManager()
    
    private struct Const {
        static let name = "pisces.orange.RealmManager"
    }
    
    // MARK: - Properties
    
    private var isUseSerialQueue: Bool = true
    
    public var realm: Realm {
        var realm: Realm!
        perform {
            do {
                realm = try Realm(configuration: self.createConfiguration())
            } catch {
                do {
                    try FileManager.default.removeItem(at: self.fileURL)
                } catch {
                    print("AbstractRealmManager remove realm error \(error.localizedDescription)")
                }
                
                realm = try! Realm(configuration: self.createConfiguration())
                self.clear()
                self.recover()
            }
        }
        return realm
    }
    
    // MARK: - Con(De)structor
    
    public init(isUseSerialQueue: Bool = true) {
        self.isUseSerialQueue = isUseSerialQueue
        
        configure()
    }
    
    // MARK: - Abstract
    
    open var schemaVersion: UInt64 {
        fatalError("schemaVersion has not been implemented")
    }
    
    open var fileURL: URL {
        fatalError("fileURL has not been implemented")
    }
    
    open var objectTypes: [Object.Type]? {
        fatalError("fileURL has not been implemented")
    }
    
    open func deleteAll(_ realm: Realm) {
        fatalError("deleteAll() has not been implemented")
    }
    
    open func process(forMigration migration: Migration, oldSchemaVersion: UInt64) {
        fatalError("process(forMigration:oldSchemaVersion:) has not been implemented")
    }
    
    open func recover() {
        fatalError("recover has not been implemented")
    }
    
    // MARK: - Public methods
    
    open class var shared: AbstractRealmManager {
        struct Static {
            static let instance = AbstractRealmManager()
        }
        return Static.instance
    }
    
    public func array<T: Object>(forResults results: Results<T>, unlink: Bool = false) -> [T] {
        return results.map({return unlink ? T(value: $0, schema: RLMSchema()) : $0})
    }
    
    public func clear() {
        notificationManager.removeAll()
        
        try? transaction { (realm) in
            self.deleteAll(realm)
        }
    }
    
    public func initialize() {
    }
    
    public func objects<T: Object>(_ where: String? = nil, sortProperty: Any? = nil, ascending: Bool = true, limit: Int = -1, max: Int = -1, unlink: Bool = false, filter: ((T) -> Bool)? = nil) -> [T] {
        return query(`where`, sortProperty: sortProperty, ascending: ascending, limit: limit, max: max, unlink: unlink, filter: filter).objects
    }
    
    public func perform(execution: @escaping () -> ()) {
        if !isUseSerialQueue || DispatchQueue.isCurrentQueue(queue: AbstractRealmManager.queue) {
            execution()
        } else {
            AbstractRealmManager.queue.sync {
                execution()
            }
        }
    }
    
    public func query<T: Object>(_ where: String? = nil, sortProperty: Any? = nil, ascending: Bool = true, limit: Int = -1, max: Int = -1, unlink: Bool = false, filter: ((T) -> Bool)? = nil) -> RealmQueryResult<T> {
        var results: Results<T>!
        var objects: [T] = []
        
        perform {
            results = self.results(`where`, sortProperty: sortProperty, ascending: ascending)
            let elements = self.array(forResults: results, unlink: unlink)
            
            if let filter = filter {
                for element in elements {
                    if filter(element) {
                        objects.append(element)
                    }
                }
            } else {
                objects = elements
            }
            
            if limit > -1 {
                objects = objects.count > limit ? Array(objects[0..<limit]) : objects
            }
        }
        return RealmQueryResult(notificationManager: notificationManager, objects: objects, results: results, max: max)
    }
    
    public func results<T: Object>(_ where: String? = nil, sortProperty: Any? = nil, ascending: Bool = true) -> Results<T> {
        var results: Results<T>!
        perform {
            results = self.realm.objects(T.self)
            
            if let `where` = `where` {
                results = results.filter(`where`)
            }
            
            if let properties = sortProperty as? [String] {
                for property in properties {
                    results = results.sorted(byKeyPath: property, ascending: ascending)
                }
            } else if let sortProperty = sortProperty as? String {
                results = results.sorted(byKeyPath: sortProperty, ascending: ascending)
            }
        }
        return results
    }
    
    public func transaction(_ realm: Realm? = nil, execution: @escaping (Realm) -> ()) throws {
        var _error: Error?
        
        perform {
            let realm = realm == nil ? self.realm : realm!
            if realm.isInWriteTransaction {
                execution(realm)
            } else {
                do {
                    realm.beginWrite()
                    execution(realm)
                    try realm.commitWrite()
                } catch {
                    realm.cancelWrite()
                    _error = error
                }
            }
        }
        
        if let error = _error {
            throw error
        }
    }
    
    // MARK: - Internal methods
    
    internal func configure() {
    }
    
    internal func createConfiguration() -> Realm.Configuration {
        return Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: schemaVersion,
            migrationBlock: { (migration, oldSchemaVersion) in
                if oldSchemaVersion < self.schemaVersion {
                    self.process(forMigration: migration, oldSchemaVersion: oldSchemaVersion)
                }
            },
            objectTypes: objectTypes
        )
    }
}

extension List where Element: Object {
    subscript() -> [Element] {
        get {
            return Array(self)
        }
    }
}

extension DispatchQueue {
    public class func isCurrentQueue(queue: DispatchQueue) -> Bool {
        return queue.label == String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
