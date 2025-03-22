//
//  CharacterDetailItem.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 21.03.2025.
//

import UIKit

struct CharacterDetailItem: Identifiable {
    let id: Int
    let name: String
    let statusColor: UIColor
    let status: String
    let species: String
    let gender: String
    let origin: String
    let location: String
    let imageUrl: String
    let episodes: [String]
}
