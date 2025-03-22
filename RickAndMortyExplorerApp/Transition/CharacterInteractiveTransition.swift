//
//  CharacterInteractiveTransition.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 19.03.2025.
//

import UIKit

class CharacterInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var isInteractionInProgress = false
    private weak var viewController: UIViewController?
    private var shouldCompleteTransition = false
    
    // Добавляем свойства для улучшения поведения интерактивной отмены
    private var initalTranslation: CGPoint = .zero
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        setupGestureRecognizer(on: viewController.view)
        
        // Настраиваем поведение интерактивного перехода
        self.completionSpeed = 0.5  // Более плавное завершение
        self.completionCurve = .easeInOut
    }
    
    private func setupGestureRecognizer(on view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        
        // Определяем, достаточно ли смещения для завершения перехода
        let progress = translation.x / (gestureRecognizer.view?.bounds.width ?? 1.0)
        let adjustedProgress = max(0.0, min(1.0, progress))
        
        // Проверяем скорость свайпа - если она высокая, можно завершить при меньшем смещении
        let isVelocityFastEnough = velocity.x > 500
        
        switch gestureRecognizer.state {
        case .began:
            initalTranslation = translation
            isInteractionInProgress = true
            viewController?.navigationController?.popViewController(animated: true)
        
        case .changed:
            shouldCompleteTransition = adjustedProgress > 0.4 || isVelocityFastEnough
            update(adjustedProgress)
            
        case .cancelled:
            isInteractionInProgress = false
            cancel()
            
            resetViewState()
            
        case .ended:
            isInteractionInProgress = false
            
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
                
                resetViewState()
            }
            
        default:
            break
        }
    }
    
    // Добавляем метод для сброса состояния представления при отмене перехода
    private func resetViewState() {
        // Находим topViewController у navigationController и сбрасываем его transform
        if let viewController = viewController?.navigationController?.viewControllers.last {
            UIView.animate(withDuration: 0.2) {
                viewController.view.transform = .identity
                viewController.view.alpha = 1.0
            }
        }
    }
}
