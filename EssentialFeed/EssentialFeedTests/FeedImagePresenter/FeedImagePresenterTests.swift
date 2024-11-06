//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation
import EssentialFeed
import XCTest

struct FeedImageViewModel {
    let location: String?
    let description: String?
    let url: URL
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
}


protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
    
    private var view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(for model: FeedImage, with error: Error) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            url: model.imageURL,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        )
    }
}

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
    
}

extension FeedImagePresenterTests {
    private final class ViewSpy: FeedImageView {
            
        var messages: [FeedImageViewModel] = []
        
        func display(_ model: FeedImageViewModel) {
            messages.append(model)
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }

}

extension FeedImageViewModel: Equatable {
    static func == (lhs: FeedImageViewModel, rhs: FeedImageViewModel) -> Bool {
        lhs.url == rhs.url
    }
}
