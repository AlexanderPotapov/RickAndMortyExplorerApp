//
//  NetworkServiceProtocol.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

public protocol NetworkServiceProtocol {
    func request(with urlString: String) async throws -> NetworkResponse
}
