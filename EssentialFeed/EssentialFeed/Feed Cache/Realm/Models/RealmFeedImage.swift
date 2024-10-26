//
//  RealmFeedImage.swift
//  EssentialFeed
//
//  Created by Anthony on 23/10/24.
//

import Foundation
import RealmSwift

class RealmFeedImage: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var imageDescription: String?
    @Persisted var location: String?
    @Persisted var url: String
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: URL(string: url)!)
    }
    
    static func realmImages(from localFeeds: [LocalFeedImage]) -> [RealmFeedImage] {
        localFeeds.map {
            var realmImage = RealmFeedImage()
            realmImage.id = $0.id
            realmImage.imageDescription = $0.description
            realmImage.location = $0.location
            realmImage.url = $0.url.absoluteString
            return realmImage
        }
    }
}

