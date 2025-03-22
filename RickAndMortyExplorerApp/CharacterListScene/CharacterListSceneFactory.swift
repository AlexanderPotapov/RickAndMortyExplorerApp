//
//  CharacterListSceneFactory.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 18.03.2025.
//

import UIKit

protocol CharacterListSceneFactoryProtocol {
    func makeCharacterListScene() -> UIViewController
}

final class CharacterListSceneFactory: CharacterListSceneFactoryProtocol {
    func makeCharacterListScene() -> UIViewController {
        // Создаем зависимости
        let networkService = NetworkService()
        let networkDataFetcher = RickAndMortyDataFetcher(networkService: networkService)
        
        // Создаем роутер и контроллер
        let router = CharacterListRouter(alertFactory: AlertFactory(), detailFactory: CharacterDetailFactory())
        let viewController = CharacterListViewController(dataFetcher: networkDataFetcher)
        
        // Связываем компоненты
        viewController.setRouter(router)
        router.setRootViewController(root: viewController)
        
        return viewController
    }
}
