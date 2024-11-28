//
//  FeedImageLoaderWithFallbackCompositetests.swift
//  EssentialApp
//
//  Created by Anthony on 21/11/24.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialApp

class FeedImageLoaderWithFallbackCompositetests: XCTestCase, FeedImageDataLoaderTest {
    
    func test_loadImageData_doesNotRequestImageURLWhenInit() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.loadedURLs.isEmpty)
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryFirst() {
     
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        
        XCTAssertEqual(primary.loadedURLs, [expectedImageURL])
        XCTAssertTrue(fallback.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromFallBackOnPrimaryFails() {
        let expectedImageURL = makeAnyUrl()
        let expectedData = makeAnyData()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedData)) {
            primary.completeLoad(with: .failure(makeAnyError()))
            fallback.completeLoad(with: .success(expectedData))
        }
    }
    
    func test_loadImageData_loadsfromFallBackOnPrimaryFails2() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        primary.completeLoad(with: .failure(makeAnyError()))
        
        XCTAssertEqual(fallback.loadedURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_cancelsTaskCancelPrimaryLoad() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, _) = makeSUT()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        task.cancel()
        primary.completeLoad(with: .success(makeAnyData()))
        
        XCTAssertEqual(primary.cancelledURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_cencelsTaskCancelFallbackLoadOnPrimaryFailure() {
        let expectedImageURL = makeAnyUrl()
        let (sut, primary, fallback) = makeSUT()
        
        let task = sut.loadImageData(from: expectedImageURL, completion: {_ in })
        primary.completeLoad(with: .failure(makeAnyError()))
        task.cancel()
        
        XCTAssertEqual(fallback.cancelledURLs,  [expectedImageURL])
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimarySucceeds() {
        let expectedImageURL = makeAnyUrl()
        let expectedImageData = makeAnyData()
        let (sut, primary, _) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedImageData)) {
            primary.completeLoad(with: .success(expectedImageData))
        }
    }
    
    func test_loadImageData_deliversFallbackDataOnFallBackSucceeds() {
        let expectedImageURL = makeAnyUrl()
        let expectedImageData = makeAnyData()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .success(expectedImageData)) {
            primary.completeLoad(with: .failure(makeAnyError()))
            fallback.completeLoad(with: .success(expectedImageData))
        }
    }
    
    func test_loadImageData_deliversErrorWhenBothPrimaryAndFallBackFailure() {
        let expectedImageURL = makeAnyUrl()
        let error = makeAnyError()
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut: sut, toLoad: expectedImageURL, with: .failure(error)) {
            primary.completeLoad(with: .failure(error))
            fallback.completeLoad(with: .failure(error))
        }
    }
}

extension FeedImageLoaderWithFallbackCompositetests {
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primary: FeedImageDataLoaderSpy, fallback: FeedImageDataLoaderSpy) {
        let primary = FeedImageDataLoaderSpy()
        let fallback = FeedImageDataLoaderSpy()
        
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        
        return (sut, primary, fallback)
    }
}
