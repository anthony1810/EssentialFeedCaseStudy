//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//
import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct CodableFeedImage: Equatable, Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.url = url
        }
        
        init(feedImage: LocalFeedImage) {
            self.id = feedImage.id
            self.description = feedImage.description
            self.location = feedImage.location
            self.url = feedImage.url
        }
        
        func toLocalFeedImage() -> LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    let storeURL: URL
    let queue = DispatchQueue(label: "CodableFeedStoreQueue", attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let items: [CodableFeedImage]
        let timestamp: Date
        
        var feedImages: [LocalFeedImage] {
            items.map { $0.toLocalFeedImage() }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async { [storeURL] in
            do {
                guard let data = try? Data(contentsOf: storeURL) else {
                    return completion(.empty)
                }
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                completion(.success(cache.feedImages, cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCacheCompletion) {
        
        queue.async(flags: .barrier) { [storeURL] in
            do {
                let encoder = JSONEncoder()
                let cache = Cache(items: items.map { CodableFeedImage(feedImage: $0) }, timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        queue.async(flags: .barrier) { [storeURL] in
            do {
                guard FileManager.default.fileExists(atPath: storeURL.path) else {
                    return completion(nil)
                }
                
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
