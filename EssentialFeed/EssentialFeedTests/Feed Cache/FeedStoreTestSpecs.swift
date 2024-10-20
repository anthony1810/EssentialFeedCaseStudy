//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 20/10/24.
//

typealias FailableFeedStore = FailableRetrieveFeedStoreSpec & FailableInsertFeedStoreSpec & FailableDeleteFeedStoreSpec
protocol FeedStoreTestSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_insertThenRetrieveExpectedvalue()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_overridePreviousValue()
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_runSerially_executesTasksInOrder()
}

protocol FailableRetrieveFeedStoreSpec: FeedStoreTestSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnRetrievalError()
}

protocol FailableInsertFeedStoreSpec: FeedStoreTestSpecs {
    func test_insert_deliversErrorWhenEncounterFailure()
}

protocol FailableDeleteFeedStoreSpec: FeedStoreTestSpecs {
    func test_delete_deliversErrorOnDeletionFailure()
}
