//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

enum LoadFeedResult<Error: Swift.Error>: Equatable where Error: Equatable {
	case success([FeedItem])
	case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error, Equatable
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
