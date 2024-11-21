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
        _ = primary.loadImageData(from: url, completion: completion)
        return Task()
    }
}

class FeedImageLoaderWithFallbackCompositetests: XCTestCase {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        
        let _ = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        
        XCTAssertTrue(primary.requestedURLs.isEmpty)
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryFirst() {
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        let expectedImageURL = makeAnyUrl()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        
        XCTAssertEqual(primary.requestedURLs, [expectedImageURL])
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
}

extension FeedImageLoaderWithFallbackCompositetests {
    
    
    private class LoaderSpy: FeedImageLoaderProtocol {
        var messages = [(url: URL, completion: ((FeedImageLoaderProtocol.Result) -> Void))]()
        var requestedURLs: [URL] {
            messages.map(\.url)
        }
        
        private class Task: ImageLoadingDataTaskProtocol {
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageLoaderProtocol.Result) -> Void) -> ImageLoadingDataTaskProtocol {
            messages.append((url, completion))
            
            return Task()
        }
    }
}
