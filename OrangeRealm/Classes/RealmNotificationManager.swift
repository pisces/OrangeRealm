//
//  RealmNotificationManager.swift
//  OrangeRealm
//
//  Created by Steve Kim on 23/4/17.
//
//

import RealmSwift

public class RealmNotificationManager {
    
    // MARK: - Properties
    
    public private(set) var realmTokens: [NotificationToken] = []
    
    // MARK: - Public methods
    
    public func append(_ token: NotificationToken?) {
        if let token = token, !realmTokens.contains(token) {
            realmTokens.append(token)
        }
    }
    
    public func remove(_ token: NotificationToken?) {
        if let token = token, let index = realmTokens.index(of: token) {
            AbstractRealmManager.shared.perform {
                token.stop()
            }
            
            realmTokens.remove(at: index)
        }
    }
    
    public func removeAll() {
        for token in realmTokens {
            remove(token)
        }
    }
}
