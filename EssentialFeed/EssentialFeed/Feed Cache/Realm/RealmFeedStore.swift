//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 23/10/24.
//
import Foundation
import RealmSwift

public class RealmFeedStore {
    
    let realmConfig: Realm.Configuration
    
    public init (realmConfig: Realm.Configuration = .defaultConfiguration) {
        self.realmConfig = realmConfig
    }
    
    public func clearCache() {
        guard let realm = try? Realm(configuration: realmConfig) else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }
}


extension RealmFeedStore {
    public func makeRealm() throws -> Realm {
        let realm = try Realm(configuration: realmConfig)
        return realm
    }
}
