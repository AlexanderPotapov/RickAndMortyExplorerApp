//
//  CharacterDetailViewController.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import Foundation

import SwiftUI

final class CharacterDetailViewController<ViewModel>: UIViewController
where ViewModel: CharacterDetailViewModelProtocol {
    // MARK: - Properties
    
    private let viewModel: ViewModel
    private let hostingController: UIHostingController<CharacterDetailView<ViewModel>>
    
    // MARK: - Initialization
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        let detailView = CharacterDetailView(viewModel: viewModel)
        self.hostingController = UIHostingController(rootView: detailView)
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
        // Добавляем контроллер как дочерний
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Настраиваем констрейнты
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            hostingController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            hostingController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            hostingController.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
        
        hostingController.didMove(toParent: self)
    }
} 
