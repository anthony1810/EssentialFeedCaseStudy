//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Anthony on 8/2/25.
//
import CoreData

class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}
