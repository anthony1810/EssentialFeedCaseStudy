//
//  RealmFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 20/11/24.
//
import Foundation
import RealmSwift

extension RealmFeedStore: FeedStoreProtocol {
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        do {
            let realm = try makeRealm()
           
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
            let realm = try makeRealm()
            
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
            let realm = try makeRealm()
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

