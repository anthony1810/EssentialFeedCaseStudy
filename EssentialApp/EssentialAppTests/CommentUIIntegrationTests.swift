//
//  CommentUIIntegrationTests.swift
//  EssentialApp
//
//  Created by Anthony on 17/8/25.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp
import Combine

final class CommentUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentCallCount, 0, "Expected no loading requests before view is loaded.")
        
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadCommentCallCount, 1, "Expected a loading request once view is loaded.")
        
        loader.completeCommentsLoading()
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 2,"Expected another loading requests once user initiates a load.")
        
        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentCallCount, 3, "Expected a third loading requests once a user initiates another load.")
    }
    
    func test_loadingCommentIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded.")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully.")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload.")
        
        loader.completeCommentLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error.")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComment() {
        let comment0 = makeComment(message: "a message", createdAt: Date(), username: "a username")
        let comment1 = makeComment(message: "another message", createdAt: Date(), username: "another username")
       
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedCommentsViews(), 1)
        
        let _ = sut.commentView(at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadedCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeComment(message: "a message", createdAt: Date(), username: "any username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, loadError, "Expect error message to be nil initially")
        XCTAssertEqual(sut.isErrorViewVisible, true, "Expect error view to be shown initially")
        
        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage, "Expect error message to be nil when reload")
    }
    
    func test_commentView_dispatchesFromBackgroundToMainThread() {
        let comment0 = makeComment(message: "a message", createdAt: Date(), username: "any username")
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
       
        let expectation = self.expectation(description: "Expected Comments to dispatch comments loading from background to main thread")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(with: [comment0], at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let comment0 = makeComment(message: "a message", createdAt: Date(), username: "any username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment0])
        
        sut.simulateFeedImageViewVisible(at: 0)
        let expectation = self.expectation(description: "Expected image view to dispatch image loading from background to main thread")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(with: [comment0])
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_deinit_cancelsRunningRequest() {
        var cancelCallCount = 0
        var sut: ListViewController?
        autoreleasepool {
            sut = CommentUIComposer.commentsComposedWith(commentLoaderPublisher: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    })
                    .eraseToAnyPublisher()
            })
            sut?.simulateAppearance()
        }
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        XCTAssertEqual(cancelCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentUIComposer.commentsComposedWith(commentLoaderPublisher: loader.loadPublisher)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeComment(message: String, createdAt: Date, username: String ) -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: createdAt, username: username)
    }
    
    func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedCommentsViews() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentsViews()) instead.", file: file, line: line)
        }
        let commentsViewModel = ImageCommentPresenter.map(comments)
        commentsViewModel.comments.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor comment: ImageCommentViewModel, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let commentMessage = sut.commentMessage(at: index)
        let commentAuthor = sut.commentAuthor(at: index)
        let commentDate = sut.commentDate(at: index)
        
        
        XCTAssertEqual(
            commentMessage,
            comment.message,
            "Expected \(comment.message) but got \(String(describing: commentMessage))",
            file: file,
            line: line
        )
        XCTAssertEqual(
            commentAuthor,
            comment.username,
            "Expected \(comment.username) but got \(String(describing: commentAuthor))",
            file: file,
            line: line
        )
        XCTAssertEqual(
            commentDate,
            comment.date,
            "Expected \(comment.date) but got \(String(describing: commentDate))",
            file: file,
            line: line
        )
    }
    
    class LoaderSpy {
        private var commentsRequests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentCallCount: Int {
            commentsRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            commentsRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            commentsRequests[index].send(comments)
            commentsRequests[index].send(completion: .finished)
        }
        
        func completeCommentLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            commentsRequests[index].send(completion: .failure(error))
        }
    }
}
