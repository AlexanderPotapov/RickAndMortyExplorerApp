//
//  CharacterListSceneFactory.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit

protocol CharacterListSceneFactoryProtocol {
    func makeCharacterListScene() -> UIViewController
}

final class CharacterListSceneFactory: CharacterListSceneFactoryProtocol {
    func makeCharacterListScene() -> UIViewController {
        let networkService = NetworkService()
        let networkDataFetcher = RickAndMortyDataFetcher(networkService: networkService)
        let router = CharacterListRouter(alertFactory: AlertFactory(),
                                         detailFactory: CharacterDetailFactory())
        let viewController = CharacterListViewController(dataFetcher: networkDataFetcher)
        
        viewController.setRouter(router)
        router.setRootViewController(root: viewController)
        
        return viewController
    }
}
