//
//  RealmQueryResult.swift
//  OrangeRealm
//
//  Created by Steve Kim on 23/04/2017.
//
//

import RealmSwift

public typealias RealmQueryResultChanged = (Int, [IndexPath], [IndexPath], [IndexPath]) -> ()

public class RealmQueryResult<T: Object> {
    
    // MARK: - Properties
    
    public private(set) var realmToken: NotificationToken?
    
    private var changedBlock: RealmQueryResultChanged? {
        didSet {
            if changedBlock != nil {
                removeNotification()
                addNotification()
            }
        }
    }
    
    public private(set) var max: Int = -1
    public private(set) var section: Int = 0
    public private(set) var start: Int = 0
    public private(set) var objects: [T] = []
    public private(set) var results: Results<T>
    public private(set) var notificationManager: RealmNotificationManager!
    
    // MARK: - Con(De)structor
    
    deinit {
        clear()
    }
    
    public init(notificationManager: RealmNotificationManager, objects: [T], results: Results<T>, section: Int = 0, start: Int = 0, max: Int = -1) {
        self.notificationManager = notificationManager
        self.objects = objects
        self.results = results
        self.section = section
        self.start = start
        self.max = max
    }
    
    // MARK: - Public methods
    
    public func append(result: RealmQueryResult) -> [IndexPath] {
        let count = objects.count
        if max < 0 {
            objects.append(contentsOf: result.objects)
        } else if objects.count + result.objects.count <= max {
            objects.append(contentsOf: result.objects)
        }
        
        let startIndex = start + count
        var indexPaths: [IndexPath] = []
        
        for i in 0..<result.objects.count {
            indexPaths.append(IndexPath(item: startIndex + i, section: section))
        }
        
        return indexPaths
    }
    
    @discardableResult
    public func changed(_ block: @escaping RealmQueryResultChanged) -> RealmQueryResult<T> {
        self.changedBlock = block
        return self
    }
    
    public func clear() {
        objects.removeAll()
        removeNotification()
        changedBlock = nil
    }
    
    @discardableResult
    public func set(section: Int = 0, start: Int = 0) -> RealmQueryResult<T> {
        self.section = section
        self.start = start
        return self
    }
    
    // MARK: - Private methods
    
    private func addNotification() {
        realmToken = results.addNotificationBlock { [weak self] (changes) in
            guard let weakSelf = self else {return}
            
            switch changes {
            case .update(let rs, let deletions, let insertions, let modifications):
                let _modifications = weakSelf.indexPaths(modifications: modifications, rs: rs)
                let _deletions = weakSelf.indexPaths(deletions: deletions, rs: rs)
                let _insertions = weakSelf.indexPaths(insertions: insertions, rs: rs)
                
                if _deletions.count + _insertions.count + _modifications.count > 0 {
                    weakSelf.changedBlock?(weakSelf.section, _deletions, _insertions, _modifications)
                }
                break
            default:
                break
            }
        }
        
        notificationManager.append(realmToken)
    }
    
    private func indexPaths(deletions: [Int], rs: Results<T>) -> [IndexPath] {
        guard deletions.count > 0 else {return []}
        
        var objects: [T] = []
        var indexPaths: [IndexPath] = []
        for deletion in deletions {
            guard deletion < self.objects.count else {break}
            
            let object = self.objects[deletion]
            objects.append(object)
            indexPaths.append(IndexPath(item: start + deletion, section: section))
        }
        for object in objects {
            if let index = self.objects.index(of: object) {
                self.objects.remove(at: index)
            }
        }
        return indexPaths
    }
    
    private func indexPaths(insertions: [Int], rs: Results<T>) -> [IndexPath] {
        guard insertions.count > 0 else {return []}
        
        var indexPaths: [IndexPath] = []
        for insertion in insertions {
            if max > -1, objects.count + 1 > max {break}
            
            let object = rs[insertion]
            objects.insert(object, at: insertion)
            indexPaths.append(IndexPath(item: start + insertion, section: section))
        }
        return indexPaths
    }
    
    private func indexPaths(modifications: [Int], rs: Results<T>) -> [IndexPath] {
        guard modifications.count > 0 else {return []}
        
        var indexPaths: [IndexPath] = []
        for modification in modifications {
            guard modification < objects.count else {continue}
            
            let object = objects[modification]
            if let index = objects.index(of: object) {
                indexPaths.append(IndexPath(item: start + index, section: section))
            }
        }
        return indexPaths
    }
    
    private func removeNotification() {
        notificationManager.remove(realmToken)
        realmToken = nil
    }
}
