//
//  CharacterListItem.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 17.03.2025.
//

import UIKit

struct CharacterListItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let imageUrl: String
    let statusColor: UIColor
}
