import Foundation

final class ProfileImageService {
    
    private struct UserResult: Codable {
        let profileImage: ProfileImage
    }
    
    private struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private let oAuthTokenStorage = OAuth2TokenStorage()
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET"),
              let token = oAuthTokenStorage.token else {
                  assertionFailure("Failed to make HTTP request")
                  return
              }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result:Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let user):
                completion(.success(user.profileImage.large))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": user.profileImage.large])
                self.avatarURL = user.profileImage.large
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
