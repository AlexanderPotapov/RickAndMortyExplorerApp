//
//  CharacterResponse.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import Foundation

struct CharacterResponse: Decodable {
    let info: Info
    let results: [Character]
}

struct Info: Decodable {
    let next: String?
}

struct Character: Decodable {
    let id: Int
    let name: String
    let status: Status
    let species: String
    let type: String
    let gender: String
    let origin: Location
    let location: Location
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct Location: Codable {
    let name: String
    let url: String
}

enum Status: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}


struct APIError: Decodable {
    let error: String
}
