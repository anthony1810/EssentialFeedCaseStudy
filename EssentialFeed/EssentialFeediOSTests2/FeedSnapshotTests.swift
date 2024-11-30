//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests2
//
//  Created by Anthony on 28/11/24.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

final class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithImages() {
        let sut = makeSUT()
        
        sut.display(feedWithContents())
        
        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
}

extension FeedSnapshotTests {
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        controller.beginAppearanceTransition(true, animated: false) //view appear again
        controller.endAppearanceTransition()
        
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        []
    }
    
    private func feedWithContents() -> [FeedStub] {
        [
            FeedStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red), url: URL(string: "http://anyurl.com")!
            ),
            FeedStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green), url: URL(string: "http://anyurl.com")!
            )
        ]
    }
    
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate png data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot: \(error)", file: file, line: line)
        }
    }
}

class FeedStub: FeedImageDataControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?, url: URL) {
        viewModel = FeedImageViewModel(location: location, description: description, url: url, image: image, isLoading: false, shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
}

extension FeedViewController {
    func display(_ cells: [FeedImageCellController]) {
        self.tableModels = cells
    }
    
    func display(_ stubs: [FeedStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            
            return cellController
        }
        
        display(cells)
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

extension UIImage {
     static func make(withColor color: UIColor) -> UIImage {
         let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
         UIGraphicsBeginImageContext(rect.size)
         let context = UIGraphicsGetCurrentContext()!
         context.setFillColor(color.cgColor)
         context.fill(rect)
         let img = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return img!
     }
 }
