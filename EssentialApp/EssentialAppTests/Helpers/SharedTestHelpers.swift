//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Anthony on 21/8/25.
//
import EssentialFeed
import EssentialFeediOS

private class DummyResourceView: ResourceView {
    typealias ResourceViewModel = Any
    func display(_ viewModel: ResourceViewModel) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyResourceView>.loadError
}

var commentTitle: String {
    ImageCommentPresenter.title
}

var feedTitle: String {
    FeedPresenter.title
}
