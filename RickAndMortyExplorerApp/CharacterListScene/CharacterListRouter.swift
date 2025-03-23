//
//  CharacterListRouter.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit

protocol CharacterListRouterProtocol {
    func openDetail(with character: Character, from cell: UITableViewCell)
    func showAlert(title: String, message: String)
}

final class CharacterListRouter: NSObject, CharacterListRouterProtocol {
    private weak var root: UIViewController?
    private let alertFactory: AlertFactoryProtocol
    private let detailFactory: CharacterDetailFactoryProtocol
    private var selectedCell: UITableViewCell?
    private var interactiveTransition: CharacterInteractiveTransition?
    
    init(alertFactory: AlertFactoryProtocol, detailFactory: CharacterDetailFactoryProtocol) {
        self.alertFactory = alertFactory
        self.detailFactory = detailFactory
        super.init()
    }
    
    
    func openDetail(with character: Character, from cell: UITableViewCell) {
        self.selectedCell = cell
        
        // Создаем детальный экран с помощью фабрики
        let detailViewController = detailFactory.makeCharacterDetailScene(with: character)
        
        // Устанавливаем себя делегатом навигационного контроллера для кастомной анимации
        root?.navigationController?.delegate = self
        
        // Переходим на детальный экран
        root?.navigationController?.pushViewController(detailViewController, animated: true)
        
        // Инициализируем интерактивный переход на новом контроллере
        DispatchQueue.main.async { [weak self] in
            if let detailVC = self?.root?.navigationController?.topViewController {
                self?.interactiveTransition = CharacterInteractiveTransition(
                    viewController: detailVC
                )
            }
        }
    }
    
    
    func showAlert(title: String, message: String) {
        let alertController = alertFactory.makeAlert(title: title, message: message)
        root?.navigationController?.topViewController?.present(
            alertController,
            animated: true,
            completion: nil
        )
    }
    
    func setRootViewController(root: UIViewController) {
        self.root = root
    }
}

// MARK: - Navigation Controller Delegate

extension CharacterListRouter: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        // Применяем нашу анимацию как для перехода вперед, так и назад
        return CharacterTransitionAnimator(
            selectedCell: selectedCell,
            isPush: operation == .push
        )
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        
        // Проверяем, что интерактивный переход инициализирован и активен
        guard let interactiveTransition = interactiveTransition,
              interactiveTransition.isInteractionInProgress else {
            return nil
        }
        
        return interactiveTransition
    }
}
