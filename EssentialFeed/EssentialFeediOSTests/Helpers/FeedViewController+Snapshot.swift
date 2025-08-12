//
//  FeedViewController+Snapshot.swift
//  EssentialFeed
//
//  Created by Anthony on 26/7/25.
//
import EssentialFeed
import EssentialFeediOS

extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        self.display(
            stubs.map { stub in
                let controller = FeedImageCellController(delegate: stub, viewModel: stub.viewModel)
                stub.controller = controller
                return CellController(ds: controller)
            }
        )
    }
}
