//
//  RickAndMortyDataFetcher.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

// MARK: - RickAndMortyDataFetcherProtocol

protocol RickAndMortyDataFetcherProtocol {
    func fetchCharacters(page: Int, name: String?, status: Status?) async throws -> CharacterResponse
}

// MARK: - RickAndMortyDataFetcher

final class RickAndMortyDataFetcher: RickAndMortyDataFetcherProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let baseURL = "https://rickandmortyapi.com/api"
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchCharacters(page: Int, name: String? = nil, status: Status? = nil) async throws -> CharacterResponse {
        // Формируем URL с параметрами
        var urlComponents = URLComponents(string: "\(baseURL)/character")!
        var queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        
        if let name = name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: name))
        }
        
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        let url = urlComponents.url?.absoluteString ?? "\(baseURL)/character?page=\(page)"
        
        // Выполняем запрос
        let response = try await networkService.request(with: url)
        
        // Сначала проверяем статус-код
        guard (200...299).contains(response.statusCode) else {
            if let data = response.data, let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                print(apiError.error)
            }
            throw NetworkError.badStatusCode(statusCode: response.statusCode)
        }
        
        // Затем проверяем наличие данных
        guard let data = response.data else {
            throw NetworkError.noData
        }
        
        do {
            return try JSONDecoder().decode(CharacterResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
