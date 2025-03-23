//
//  CharacterDetailFactory.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit

protocol CharacterDetailFactoryProtocol {
    func makeCharacterDetailScene(with character: Character) -> UIViewController
}

final class CharacterDetailFactory: CharacterDetailFactoryProtocol {
    
    func makeCharacterDetailScene(with character: Character) -> UIViewController {
        let viewModel = CharacterDetailViewModel(character: character)
        let viewController = CharacterDetailViewController<CharacterDetailViewModel>(viewModel: viewModel)
        return viewController
    }
}
