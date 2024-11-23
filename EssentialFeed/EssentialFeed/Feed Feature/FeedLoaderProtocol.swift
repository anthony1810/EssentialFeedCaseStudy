//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedLoaderProtocol {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
