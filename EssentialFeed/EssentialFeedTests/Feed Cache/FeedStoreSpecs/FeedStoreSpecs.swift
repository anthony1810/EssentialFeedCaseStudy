//
//  FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache() throws
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() throws
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() throws
    func test_retrieve_deliversFoundCacheHasNoSideEffects() throws
   

    func test_insert_overridesExistingCacheOnNonEmptyCache() throws
    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect() throws
   

    func test_delete_deliversSuccessOnEmptyCache() throws
    func test_delete_deliversSuccessOnNonEmptyCache() throws
   
    func test_storeSideEffects_runSerially() throws
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorWhenThereIsError() throws
    func test_retrieve_deliversErrorWhenThereIsErrorHasNoSideEffect() throws
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorWhenThereIsError() throws
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorWhenThereIsError() throws
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
