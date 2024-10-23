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
    
    deinit {
        let realm = try! Realm(configuration: realmConfig)
        try! realm.write {
            realm.deleteAll()
        }
    }
}

extension RealmFeedStore: FeedStoreProtocol {
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        
    }
    
    public func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        do {
            let realm = try Realm(configuration: realmConfig)
            
            let cache = RealmCache()
            cache.timestamp = timestamp
            cache.feeds.append(objectsIn: RealmFeedImage.realmImages(from: items))
            
            try realm.write {
                realm.add(cache, update: .all)
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            let realm = try Realm(configuration: realmConfig)
            if let cache = realm.objects(RealmCache.self).first {
                completion(.success(cache.feeds.map(\.local), cache.timestamp))
            } else {
                completion(.empty)
            }
        } catch {
            completion(.failure(error))
        }
    }
}
