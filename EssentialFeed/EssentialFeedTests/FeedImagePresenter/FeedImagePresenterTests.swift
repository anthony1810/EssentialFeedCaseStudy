//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation
import EssentialFeed
import XCTest


final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendAnyMessage() {
        let (_, view) = makeSUT()
        XCTAssertEqual(view.messages.count, 0)
    }
    
    func test_startLoadingImage_showLoadingAndDoesNotShowRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueItem().domainModel
        
        sut.didStartLoadingImageData(for: image)
        
        
        let message = view.messages.first
        XCTAssertFalse(view.messages.isEmpty)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNil(message?.image)
        
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, true)
    }
    
    func test_finishedLoadingImage_showRetryOnFailLoading() {
        let (sut, view) = makeSUT()
        let image = uniqueItem().domainModel
        
        sut.didFinishLoadingImageData(for: image, with: makeAnyError())
            
        let message = view.messages.first
        XCTAssertFalse(view.messages.isEmpty)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
    }
    
    func test_finishedLoadingImage_showRetryForInvalidImageData() {
        let (sut, view) = makeSUT()
        let image = uniqueItem().domainModel
        
        sut.didFinishLoadingImageData(for: image, with: makeAnyData())
        
        let message = view.messages.first
        XCTAssertFalse(view.messages.isEmpty)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
    }
    
    func test_finishedLoadingImage_showImage() {
        let (sut, view) = makeSUT(imageTransformer: { _ in AnyImage() })
        let image = uniqueItem().domainModel
        
        sut.didFinishLoadingImageData(for: image, with: makeAnyData())
        
        let message = view.messages.first
        XCTAssertFalse(view.messages.isEmpty)
        
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertNotNil(message?.image)
        
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, false)
    }
    
}

extension FeedImagePresenterTests {
    private final class ViewSpy: FeedImageView {
        typealias Image = AnyImage
        var messages: [FeedImageViewModel<AnyImage>] = []
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
    private func makeSUT(
        imageTransformer: @escaping ((Data) -> AnyImage?) = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<AnyImage, ViewSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private var fail: (Data) -> Any? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }

}

extension FeedImageViewModel: @retroactive Equatable {
    public static func == (lhs: FeedImageViewModel, rhs: FeedImageViewModel) -> Bool {
        lhs.url == rhs.url
    }
}
