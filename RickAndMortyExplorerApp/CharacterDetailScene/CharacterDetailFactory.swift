//
//  CharacterDetailFactory.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 19.03.2025.
//

import UIKit

protocol CharacterDetailFactoryProtocol {
    func makeCharacterDetailModule(with character: Character) -> UIViewController
}

final class CharacterDetailFactory: CharacterDetailFactoryProtocol {
    
    func makeCharacterDetailModule(with character: Character) -> UIViewController {

        let viewModel = CharacterDetailViewModel(character: character)
        let viewController = CharacterDetailViewController(viewModel: viewModel)
        
        return viewController
    }
}
