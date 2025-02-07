//
//  FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache()
    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache()
    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache()
    func test_retrieve_deliversFoundCacheHasNoSideEffects()
   

    func test_insert_overridesExistingCacheOnNonEmptyCache()
    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect()
   

    func test_delete_deliversSuccessOnEmptyCache()
    func test_delete_deliversSuccessOnNonEmptyCache()
   
    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorWhenThereIsError()
    func test_retrieve_deliversErrorWhenThereIsErrorHasNoSideEffect()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorWhenThereIsError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorWhenThereIsError()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
