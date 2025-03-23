//
//  MockNetworkService.swift
//  RickAndMortyExplorerAppTests
//
//  Created by Alexander on 23.03.2025.
//

import Foundation
@testable import RickAndMortyExplorerApp

class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: NetworkResponse?
    var mockError: Error?
    var capturedURL: String?
    
    func request(with urlString: String) async throws -> NetworkResponse {
        capturedURL = urlString
        
        if let error = mockError {
            throw error
        }
        
        if let response = mockResponse {
            return response
        }
        
        throw NetworkError.unknown
    }
}

