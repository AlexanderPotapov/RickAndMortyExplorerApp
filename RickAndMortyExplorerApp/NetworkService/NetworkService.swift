//
//  NetworkService.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

// NetworkService реализованный с помощью URLSession
public final class NetworkService: NetworkServiceProtocol {
    public func request(with urlString: String) async throws -> NetworkResponse {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        
        return NetworkResponse(statusCode: statusCode, data: data)
    }
}
