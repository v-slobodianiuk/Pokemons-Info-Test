//
//  NetworkService.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

protocol NetworkServiceProtocol {
    var scheme: String {get}
    var host: String {get}
    var requiredPath: String {get}
    
    func urlComponents(urlPath: String, queryItems: [URLQueryItem]?) -> URL?
    func apiRequest(requestURL: URL, requestMethod: String?, _ comletion: @escaping (Result<Data?, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    internal let scheme = "https"
    internal let host = "pokeapi.co"
    internal let requiredPath = "/api/v2/"
    
    func urlComponents(urlPath: String, queryItems: [URLQueryItem]?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(requiredPath)\(urlPath)"
        components.queryItems = queryItems
        
        guard let requestURL = components.url else { return nil }
        
        return requestURL
    }
    
    func apiRequest(requestURL: URL, requestMethod: String?, _ comletion: @escaping (Result<Data?, Error>) -> Void) {
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = requestMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                comletion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { return }
            
            switch response.statusCode {
            case 200 ... 299:
                comletion(.success(data))
            case 404:
                comletion(.failure(NetworkError.notFound))
            default:
                comletion(.failure(NetworkError.unknown))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case notFound
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        case .notFound:
            return NSLocalizedString("Not Found. Please try again", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "")
        }
    }
}
