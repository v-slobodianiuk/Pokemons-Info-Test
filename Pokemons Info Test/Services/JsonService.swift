//
//  JsonService.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import Foundation

protocol JsonServiceProtocol {
    func jsonDecode<T: Codable>(data: Data?) -> T?
    func jsonEncode<T: Codable>(model: T) -> Data?
}

class JsonServise: JsonServiceProtocol {
    
    static let shared = JsonServise()
    
    func jsonDecode<T: Codable>(data: Data?) -> T? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(T.self, from: data) else { return nil }
        return decodedData
    }
    
    func jsonEncode<T: Codable>(model: T) -> Data? {
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(model) else { return nil }
        return encodedData
    }
}
