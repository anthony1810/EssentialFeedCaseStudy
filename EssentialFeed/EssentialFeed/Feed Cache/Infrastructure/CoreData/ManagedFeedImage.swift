//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Anthony on 8/2/25.
//
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data
    @NSManaged var cache: ManagedCache
}
