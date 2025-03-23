//
//  CharacterListViewController.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit

final class CharacterListViewController: UIViewController {
    
    // MARK: - Properties
    var router: CharacterListRouterProtocol?
    
    private let dataFetcher: RickAndMortyDataFetcherProtocol
    private var state = CharacterListState()
    private var currentTask: Task<Void, Never>?
    
    
    // MARK: - UI Components
    
    private lazy var characterListView: CharacterListView = {
        let view = CharacterListView()
        
        // Настраиваем обработчики событий
        view.onCharacterSelected = { [weak self] characterItem, cell in
            guard let cell = cell else { return }
            self?.handleCharacterSelection(characterItem, from: cell)
        }
        
        view.onReachEndOfList = { [weak self] in
            self?.loadCharacters()
        }
        
        view.onSearch = { [weak self] query in
            self?.handleSearch(query)
        }
        
        view.onFilterChange = { [weak self] status in
            self?.handleFilterChange(status)
        }
        
        return view
    }()
    
    // MARK: - Initialization
    
    init(dataFetcher: RickAndMortyDataFetcherProtocol) {
        self.dataFetcher = dataFetcher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = characterListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadCharacters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Public Methods
    
    func setRouter(_ router: CharacterListRouterProtocol) {
        self.router = router
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBar() {
        title = "Персонажи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
    }
    
    private func updateView() {
        characterListView.updateCharacters(
            toCharacterItems(state.characters),
            isLoading: state.isLoading
        )
    }
    
    private func toCharacterItems(_ characters: [Character]) -> [CharacterListItem] {
        characters.map { CharacterListViewController.createCharacterListItem(from: $0) }
    }
    
    private static func createCharacterListItem(
        from character: Character
    ) -> CharacterListItem {
        let statusColor: UIColor
        switch character.status {
        case .alive: statusColor = .systemGreen
        case .dead: statusColor = .systemRed
        case .unknown: statusColor = .systemGray
        }
        
        return CharacterListItem(
            id: character.id,
            name: character.name,
            status: character.status.rawValue,
            species: character.species,
            imageUrl: character.image,
            statusColor: statusColor
        )
    }
    
    // MARK: - Event Handlers
    
    private func handleCharacterSelection(
        _ characterItem: CharacterListItem,
        from cell: UITableViewCell
    ) {
        // Находим соответствующий Character по ID из модели представления
        if let character = state.characters.first(where: { $0.id == characterItem.id }) {
            router?.openDetail(with: character, from: cell)
        }
    }
    
    private func handleSearch(_ query: String) {
        if query.isEmpty {
            state.resetSearch()
        } else {
            state.updateSearchQuery(query)
        }
        loadCharacters()
    }
    
    private func handleFilterChange(_ status: CharacterStatus?) {
        // Преобразуем CharacterStatus в Status
        let convertedStatus: Status?
        
        switch status {
        case .alive:
            convertedStatus = .alive
        case .dead:
            convertedStatus = .dead
        case .unknown:
            convertedStatus = .unknown
        case .none:
            convertedStatus = nil
        }
        
        // Обновляем фильтр и загружаем данные с преобразованным статусом
        state.updateStatusFilter(convertedStatus)
        loadCharacters()
    }
    
    // MARK: - Data Loading
    
    private func loadCharacters() {
        // Проверяем, есть ли еще данные для загрузки
        guard state.hasNextPage else { return }
        
        // Отменяем предыдущую задачу, если она существует
        currentTask?.cancel()
        
        // Устанавливаем состояние загрузки
        state.isLoading = true
        updateView()
        
        // Определяем параметры запроса
        let page = state.currentPage
        let name = state.isSearchActive ? state.searchQuery : nil
        let status = state.statusFilter
        
        // Создаем новую задачу
        currentTask = Task {
            defer {
                if !Task.isCancelled {
                    state.isLoading = false
                    updateView()
                }
            }
            
            do {
                // Проверка на отмену задачи
                try Task.checkCancellation()
                
                let result = try await dataFetcher.fetchCharacters(
                    page: page,
                    name: name,
                    status: status
                )
                
                // Проверка на отмену задачи после получения результата
                try Task.checkCancellation()
                
                // Обновляем состояние только если задача не была отменена
                state.hasNextPage = result.info.next != nil
                state.appendCharacters(result.results)
            } catch let networkError as NetworkError {
                // Явно обрабатываем NetworkError
                router?.showAlert(
                    title: "Ошибка сети",
                    message: networkError.errorDescription
                )
            } catch {
                // Для других ошибок
                router?.showAlert(
                    title: "Неизвестная ошибка",
                    message: error.localizedDescription
                )
            }
        }
    }
}

