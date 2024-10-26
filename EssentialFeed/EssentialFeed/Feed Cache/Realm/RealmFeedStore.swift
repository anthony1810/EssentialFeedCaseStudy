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

extension RealmFeedStore: FeedStoreProtocol {
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        do {
            let realm = try Realm(configuration: realmConfig)
           
            let deleteAction = {
                realm.deleteAll()
                completion(nil)
            }
            
            if realm.isInWriteTransaction {
                deleteAction()
            } else {
                try realm.write {
                    deleteAction()
                }
            }
        } catch {
            completion(error)
        }
    }
    
    public func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        do {
            let realm = try Realm(configuration: realmConfig)
            
            let cache = RealmCache()
            cache.timestamp = timestamp
            cache.feeds.append(objectsIn: RealmFeedImage.realmImages(from: items))
            
            let insertAction = {
                realm.add(cache, update: .all)
                completion(nil)
            }
            
            if realm.isInWriteTransaction {
                insertAction()
            } else {
                try realm.write {
                    insertAction()
                }
            }
            
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            let realm = try Realm(configuration: realmConfig)
            if let cache = realm.objects(RealmCache.self).first {
                completion(.success(.found(cache.feeds.map(\.local), cache.timestamp)))
            } else {
                completion(.success(.empty))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
