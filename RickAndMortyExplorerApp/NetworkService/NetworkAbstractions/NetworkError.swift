//
//  NetworkError.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case decodingError(Error)
    case noData
    case badStatusCode(statusCode: Int)
    case unknown
    
    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL Error."
        case .decodingError(let error):
            return "Decoding Error with reason: \(error)."
        case .noData:
            return "No Data Error."
        case .badStatusCode(statusCode: let code):
            return "Bad Status Code Error with code: \(code)."
        case .unknown:
            return "Unknown Error."
        }
    }
}
