//
//  FeedImageLoaderWithFallbackCompositetests.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//

import Foundation
import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageLoaderProtocol {
    
    let primary: FeedImageLoaderProtocol
    let fallback: FeedImageLoaderProtocol
    
    private class Task: ImageLoadingDataTaskProtocol {
        func cancel() {
            
        }
    }
    
    init(primary: FeedImageLoaderProtocol, fallback: FeedImageLoaderProtocol) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
        
        return Task()
    }
}

class FeedImageLoaderWithFallbackCompositetests: XCTestCase {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        
        XCTAssertTrue(primary.requestedURLs.isEmpty)
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
}

extension FeedImageLoaderWithFallbackCompositetests {
    
    
    private class LoaderSpy: FeedImageLoaderProtocol {
        var requestedURLs: [URL] = []
        
        private class Task: ImageLoadingDataTaskProtocol {
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
            requestedURLs.append(url)
            
            return Task()
        }
    }
}
