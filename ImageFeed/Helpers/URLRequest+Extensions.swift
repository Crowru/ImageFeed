//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Руслан  on 08.07.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        queryItems: [URLQueryItem]? = nil,
        baseURL: URL = defaultBaseURL
    ) -> URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL), var baseUrl = URL(string: path, relativeTo: url) else {
            assertionFailure("Failed to make url")
            return nil
        }
        baseUrl.appendQueryItems(queryItems: queryItems)
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        return request
    }
    
    static func makeHTTPRequest2(
        path: String,
        httpMethod: String,
        queryItems: [URLQueryItem]? = nil,
        baseURL: String
    ) -> URLRequest? {
        
        guard
            let url = URL(string: String(describing: baseURL)),
            var baseUrl = URL(string: path, relativeTo: url)
        else { return nil }
        
        baseUrl.appendQueryItems(queryItems: queryItems)
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

extension URL {
    mutating func appendQueryItems(queryItems: [URLQueryItem]?) {
        guard let queryItems = queryItems,
              var urlComponents = URLComponents(string: absoluteString) else { return }
        
        var currentQueryItems = urlComponents.queryItems ?? []
        currentQueryItems.append(contentsOf: queryItems)
        urlComponents.queryItems = currentQueryItems
        
        if let newUrl = urlComponents.url {
            self = newUrl
        }
    }
}
