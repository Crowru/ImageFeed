import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
    let smallImageURL: String
    let isLiked: Bool
    
    init(_ photoResult: PhotoResult, date: ISO8601DateFormatter) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = date.date(from: photoResult.createdAt)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.regularImageURL = photoResult.urls.regular
        self.smallImageURL = photoResult.urls.small
        self.isLiked = photoResult.likedByUser
    }
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    
    private let dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        print("до проверки")
        if currentTask != nil {
            currentTask?.cancel()
        }
        print("после проверки")
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let request = makeRequest(page: nextPage) else {
            print("запрос не удался")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    print("Я ЗАШЕЛ В УДАЧУ")
                    if self.lastLoadedPage == nil {
                        self.lastLoadedPage = 1
                    } else {
                        self.lastLoadedPage! += 1
                    }
                    
                    let newPhotos = photoResults.map { Photo($0, date: self.dateFormatter) }
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: nil)
                    
                case .failure(let error):
                    print("я зашел в ошибку")
                    print(error.localizedDescription)
                    
                }
            }
        }
        self.currentTask = task
        task.resume()
        
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        return URLRequest.makeHTTPRequest2(path: "/photos",
                                          httpMethod: "GET",
                                          queryItems: queryItems,
                                           baseURL: String(describing: defaultBaseURL))
    }
}
