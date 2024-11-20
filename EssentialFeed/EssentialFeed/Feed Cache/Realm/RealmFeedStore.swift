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
    
    public init (realmConfig: Realm.Configuration) {
        self.realmConfig = realmConfig
    }
    
    public func clearCache() {
        if let fileURL = realmConfig.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    public func makeRealm() throws -> Realm {
        let realm = try Realm(configuration: realmConfig)
        return realm
    }
}
