//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Anthony on 5/12/24.
//
import Foundation
import EssentialFeed
import Combine

extension HTTPClient {
    typealias Publisher = AnyPublisher<(HTTPURLResponse, Data), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { promise in
                task = self.get(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel()})
        .eraseToAnyPublisher()
    }
}
