import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = authTokenRequest(code: code) else {
            fatalError("Unable to create fetch authorization token request")
        }
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Shared helpers
extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
    
    func authTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com"),
              let request = URLRequest.makeHTTPRequest(
                path: "/oauth/token"
                + "?client_id=\(accessKey)"
                + "&&client_secret=\(secretKey)"
                + "&&redirect_uri=\(redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                httpMethod: "POST",
                baseURL: url)
        else {
            return nil
        }
        return request
    }
}
