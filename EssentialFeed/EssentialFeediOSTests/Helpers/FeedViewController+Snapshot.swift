//
//  FeedViewController+Snapshot.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import EssentialFeed
import EssentialFeediOS

extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        self.display(
            stubs.map { stub in
                let controller = FeedImageCellController(delegate: stub)
                stub.controller = controller
                return controller
            }
        )
    }
}
