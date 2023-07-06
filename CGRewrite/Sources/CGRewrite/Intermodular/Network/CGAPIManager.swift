//
//  CGAPIManager.swift
//  
//
//  Created by Yasir on 06/07/23.
//

import Foundation

internal class CGAPIManager {
    static let shared = CGAPIManager()
    
    private init() { }
    
    func request<T: Decodable>(with request: CGRequest, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let safeRequest = request.urlRequest else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: safeRequest) { data, response, error in
            if let error = error {
                completion(.failure(.custom(with: error)))
                return
            }
            
            guard let response = response, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noResponse))
                return
            }
            
            guard [429, 502, 408].doesNotContains(httpResponse.statusCode) else {
                self.retryRequestWithDelay(request, responseType: responseType, completion: completion)
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    private func retryRequestWithDelay<T: Decodable>(_ request: CGRequest, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        var retryRequest = request
        guard retryRequest.maxRetry > 0 else {
            completion(.failure(.failedAfterRetrying))
            return
        }
        
        retryRequest.maxRetry -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.request(with: retryRequest, responseType: responseType, completion: completion)
        }
    }
}

internal enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case noResponse
    case failedAfterRetrying
    case custom(with: Error)
}

internal enum HTTPMethod: Codable {
    case get
    case post
    case put
    
    var value: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        }
    }
}

internal extension Array where Element: Equatable {
    func doesNotContains(_ element: Element) -> Bool {
        return !contains(element)
    }
}


