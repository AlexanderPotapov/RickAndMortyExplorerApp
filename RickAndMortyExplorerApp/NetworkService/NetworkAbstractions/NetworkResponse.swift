//
//  NetworkResponse.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

public struct NetworkResponse {
    public let statusCode: Int
    public let data: Data?

    public init(statusCode: Int, data: Data?) {
        self.statusCode = statusCode
        self.data = data
    }
}
