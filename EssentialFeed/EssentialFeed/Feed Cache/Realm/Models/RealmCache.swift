//
//  RealmCache.swift
//  EssentialFeed
//
//  Created by Anthony on 23/10/24.
//

import Foundation
import RealmSwift

class RealmCache: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var timestamp: Date
    @Persisted var feeds: List<RealmFeedImage>
}
