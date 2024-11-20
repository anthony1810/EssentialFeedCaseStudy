//
//  RealmFeedStore+FeedImageStore.swift
//  EssentialFeed
//
//  Created by Anthony on 20/11/24.
//
import Foundation
import RealmSwift

extension RealmFeedStore: LocalFeedImageStoreProtocol {
    public func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        do {
            let realm = try makeRealm()
            
            let realmImage = realm
                .objects(RealmFeedImage.self)
                .where({ $0.url == url.absoluteString })
                .first
            
            completion(.success(realmImage?.data))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        do {
            let realm = try makeRealm()
            let insertion = {
                let result = realm
                    .objects(RealmFeedImage.self)
                    .where({ $0.url == url.absoluteString })
                    .first
                    .flatMap { foundRealmImage -> Data? in
                        foundRealmImage.data = data
                        return data
                    }
                
                completion(.success(result))
            }
            
            if realm.isInWriteTransaction {
                insertion()
            } else {
                try realm.write { insertion() }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
