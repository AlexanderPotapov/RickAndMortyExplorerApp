//
//  SceneDelegate.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let sceneFactory = CharacterListSceneFactory()
        let characterListVC = sceneFactory.makeCharacterListScene()
        let navigationController = UINavigationController(rootViewController: characterListVC)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}

