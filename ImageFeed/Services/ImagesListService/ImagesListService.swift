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
        self.createdAt = date.date(from: photoResult.createdAt ?? "")
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
    let createdAt: String?
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

struct PhotoLike: Decodable {
    let photo: PhotoResult
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    
    private let dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
// MARK: Response Photo Next Page
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else { return }
       
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
                    print(error.localizedDescription)
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
// MARK: Response Change Like
    func changeLike(photoId: String, isLike: Bool, _ complition: @escaping (Result<Void, Error>) -> Void) {
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("Запрос не удался")
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<PhotoLike, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhotoResult = PhotoResult(id: photo.id,
                                                         width: Int(photo.size.width),
                                                         height: Int(photo.size.height),
                                                         createdAt: photo.createdAt?.description,
                                                         description: photo.welcomeDescription,
                                                         urls: UrlsResult(full: photo.largeImageURL,
                                                                          regular: photo.regularImageURL,
                                                                          small: photo.smallImageURL,
                                                                          thumb: photo.thumbImageURL),
                                                         likedByUser: !photo.isLiked)
                        let newPhoto = Photo(newPhotoResult, date: self.dateFormatter)
                        self.photos[index] = newPhoto
                        complition(.success(()))
                    }
                    
                case .failure(let error):
                    fatalError("error like: \(error)")
                }
            }
        }
        self.currentTask = task
        task.resume()
    }
    
// MARK: Requests
    private func makeRequest(page: Int) -> URLRequest? {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        return URLRequest.makeHTTPRequest(path: "/photos",
                                          httpMethod: "GET",
                                          queryItems: queryItems,
                                           baseURL: String(describing: defaultBaseURL))
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like",
                                    httpMethod: isLike ? "POST" : "DELETE",
                                    baseURL: String(describing: defaultBaseURL))
    }
}
