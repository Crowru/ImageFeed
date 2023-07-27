//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Руслан  on 08.07.2023.
//

import Foundation

// MARK: - Network Connection
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError(Error)
}

extension URLSession {
        
    func objectTask<DecodingType: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<DecodingType, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    print("objectTask1")
                    completion(.failure(NetworkError.urlSessionError(error)))
                }
            }
            
            if let response = response as? HTTPURLResponse {
                if !(200..<300 ~= response.statusCode) {
                    DispatchQueue.main.async {
                        print("objectTask2")
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                }
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(DecodingType.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("objectTask3")
                        completion(.failure(NetworkError.urlSessionError(error)))
                    }
                }
            }
        }
        return task
    }
}

