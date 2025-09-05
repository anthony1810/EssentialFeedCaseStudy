import Foundation
import EssentialFeediOS
import EssentialFeed
import Combine

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedImageDataLoader {
        
        // MARK: - Feed Loader
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
       
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with feedModel: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index].send(Paginated(items: feedModel, loadMorePublisher: { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                return publisher.eraseToAnyPublisher()
            }))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - LoadMoreFeedLoader
        private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        
        var loadMoreFeedCallCount: Int {
            loadMoreRequests.count
        }
        
        func completeLoadMoreFeed(lastPage: Bool, feedModel: [FeedImage] = [], at index: Int = 0) {
            loadMoreRequests[index].send(
                Paginated(
                    items: feedModel,
                    loadMorePublisher: lastPage ? nil : { [weak self] in
                        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                        self?.loadMoreRequests.append(publisher)
                        return publisher.eraseToAnyPublisher()
                    }
                )
            )
        }
        
        func completeLoadMoreFeedWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map{ $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy{ [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            imageRequests[index].completion(.failure(anyNSError()))
        }
    }
}
