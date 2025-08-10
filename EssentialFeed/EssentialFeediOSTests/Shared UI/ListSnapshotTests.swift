//
//  ListSnapshotTests.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import Foundation
import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class ListSnapshotTests: XCTestCase {
    func test_renderFeed_whenEmpty() throws {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "EMPTY_LIST")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "EMPTY_LIST_DARK")
    }
    
    func test_renderFeed_whenThereIsError() throws {
        let sut = makeSUT()
        
        sut.display(errorOccured("There is an error \n please try again later"))
        
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "ERROR_OCCURED")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "ERROR_OCCURED_DARK")
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [CellController] {
        []
    }
    
    private func errorOccured(_ message: String) -> ResourceErrorViewModel {
        .error(message: message)
    }
}
