//
//  CharacterTransitionAnimator.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 19.03.2025.
//

import UIKit

class CharacterTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.4
    private let selectedCell: UITableViewCell?
    private let isPush: Bool
    
    init(selectedCell: UITableViewCell? = nil, isPush: Bool = true) {
        self.selectedCell = selectedCell
        self.isPush = isPush
        super.init()
    }
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPush {
            animatePushTransition(using: transitionContext)
        } else {
            animatePopTransition(using: transitionContext)
        }
    }
    
    private func animatePushTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        // добавляем toVC в контейнер
        containerView.addSubview(toVC.view)
        
        
        // Создаем снимок ячейки для более плавного перехода
        let cellSnapshotView: UIView?
        if let cell = selectedCell {
            cellSnapshotView = cell.contentView.snapshotView(afterScreenUpdates: false)
            if let snapshot = cellSnapshotView {
                // Конвертируем координаты ячейки в координаты containerView
                let cellFrameInContainer = cell.convert(cell.bounds, to: containerView)
                
                snapshot.frame = cellFrameInContainer
                snapshot.alpha = 1.0
                containerView.addSubview(snapshot)
            }
        } else {
            cellSnapshotView = nil
        }
        
        // Начальная трансформация для детального представления - масштаб 0.85
        toVC.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        toVC.view.alpha = 0.0
        
        // Анимируем переход
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                // toView увеличивается до нормального размера
                toVC.view.transform = .identity
                toVC.view.alpha = 1.0
                
                // Анимируем снимок ячейки, если он есть
                if let snapshot = cellSnapshotView {
                    // Перемещаем ячейку в центр и увеличиваем
                    snapshot.center = containerView.center
                    snapshot.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    snapshot.alpha = 0.0
                }
                
                // Немного уменьшаем и затемняем исходное представление
                fromVC.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                fromVC.view.alpha = 0.0
            },
            completion: { finished in
                // Сбрасываем трансформации
                fromVC.view.transform = .identity
                fromVC.view.alpha = 1.0
                
                // Удаляем снимок ячейки
                cellSnapshotView?.removeFromSuperview()
                
                // Завершаем переход
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    private func animatePopTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let toVC = transitionContext.viewController(forKey: .to),
              let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView

        
        // Добавляем toVC ниже текущего вида для анимации
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        // Применяем начальные трансформации для анимации
        toVC.view.alpha = 0.0
        toVC.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        // Анимируем переход
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                // Уменьшаем и скрываем экран с деталями до масштаба 0.85
                fromVC.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                fromVC.view.alpha = 0.0
                
                // Показываем список и возвращаем к нормальному размеру
                toVC.view.transform = .identity
                toVC.view.alpha = 1.0
            },
            completion: { finished in
                // Сбрасываем трансформации независимо от того, была ли анимация отменена
                fromVC.view.transform = .identity
                fromVC.view.alpha = 1.0
                toVC.view.transform = .identity
                toVC.view.alpha = 1.0
                
                // Завершаем переход
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
