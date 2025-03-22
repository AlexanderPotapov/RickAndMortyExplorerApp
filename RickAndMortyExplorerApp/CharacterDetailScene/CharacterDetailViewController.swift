//
//  CharacterDetailViewController.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 19.03.2025.
//

import Foundation

import SwiftUI

final class CharacterDetailViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: CharacterDetailViewModel
    
    // MARK: - Initialization
    
    init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBar() {
        title = viewModel.detailItem.name
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        setupView()
    }
    
    private func setupView() {
        // Создаем SwiftUI представление
        let detailView = CharacterDetailView(viewModel: viewModel)
        
        // Интегрируем SwiftUI представление в UIKit
        let hostingController = UIHostingController(rootView: detailView)
        hostingController.view.backgroundColor = .systemBackground
        
        // Добавляем контроллер как дочерний
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Настраиваем констрейнты
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
} 
