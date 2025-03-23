//
//  CharacterListView.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit

enum CharacterStatus: String {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}

final class CharacterListView: UIView {
    
    // MARK: - Closures
    
    var onCharacterSelected: ((CharacterListItem, UITableViewCell?) -> Void)?
    var onReachEndOfList: (() -> Void)?
    var onSearch: ((String) -> Void)?
    var onFilterChange: ((CharacterStatus?) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск персонажей"
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        return searchBar
    }()
    
    private lazy var statusSegmentControl: UISegmentedControl = {
        let items = ["Все", "Живые", "Мертвые", "Неизвестно"]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(
            self,
            action: #selector(statusFilterChanged),
            for: .valueChanged
        )
        return segmentControl
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(
            CharacterCell.self,
            forCellReuseIdentifier: CharacterCell.reuseIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.contentInsetAdjustmentBehavior = .automatic
        
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Нет результатов"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Properties
    
    private var characters: [CharacterListItem] = []
    private var isLoading = false
    private var isKeyboardVisible = false
    private var dataSource: UITableViewDiffableDataSource<Int, CharacterListItem>?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // MARK: - Public Methods
    
    func updateCharacters(_ characters: [CharacterListItem], isLoading: Bool) {
        self.characters = characters
        self.isLoading = isLoading
        
        // Показываем или скрываем представление для пустого состояния
        emptyStateView.isHidden = !characters.isEmpty || isLoading
        
        // Обновляем таблицу через Diffable Data Source
        applySnapshot(with: characters)
        
        // Управляем индикатором загрузки
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    // MARK: - Private Methods
    
    private func applySnapshot(with items: [CharacterListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CharacterListItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Keyboard Methods
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
        // Делаем таблицу неактивной при показе клавиатуры
        tableView.isUserInteractionEnabled = false
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        // Возвращаем интерактивность таблице при скрытии клавиатуры
        tableView.isUserInteractionEnabled = true
    }
    
    // MARK: - Control
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        // Проверяем, не было ли нажатие по searchBar
        if !searchBar.frame.contains(location) {
            searchBar.resignFirstResponder()
        }
    }
    
    @objc private func statusFilterChanged(_ sender: UISegmentedControl) {
        let selectedStatus: CharacterStatus?
        
        switch sender.selectedSegmentIndex {
        case 1:
            selectedStatus = .alive
        case 2:
            selectedStatus = .dead
        case 3:
            selectedStatus = .unknown
        default:
            selectedStatus = nil
        }
        
        onFilterChange?(selectedStatus)
    }
    
    // MARK: - configureDataSource
    
    private  func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, CharacterListItem>(
            tableView: tableView
        ) { tableView, indexPath, characterItem in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CharacterCell.reuseIdentifier,
                for: indexPath
            ) as? CharacterCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: characterItem)
            return cell
        }
    }
    
    
    // MARK: - Setup Methods
    
    private func commonInit() {
        // Настраиваем внешний вид view
        backgroundColor = .systemGroupedBackground
        
        // Добавляем жест для скрытия клавиатуры при нажатии на экран
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture(_:))
        )
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        
        setupSubviews()
        configureDataSource()
    }
    
    private func setupSubviews() {
        
        addSubview(searchBar)
        addSubview(statusSegmentControl)
        addSubview(tableView)
        addSubview(activityIndicator)
        addSubview(emptyStateView)
        
        setupConstraints()
    }
    
    
    private func setupConstraints() {
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        statusSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            statusSegmentControl.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor,
                constant: 8
            ),
            statusSegmentControl.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            statusSegmentControl.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            
            tableView.topAnchor.constraint(
                equalTo: statusSegmentControl.bottomAnchor,
                constant: 8
            ),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyStateView.topAnchor.constraint(
                equalTo: statusSegmentControl.bottomAnchor,
                constant: 8
            ),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CharacterListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CharacterCell.reuseIdentifier,
            for: indexPath
        ) as? CharacterCell else {
            return UITableViewCell()
        }
        
        let character = characters[indexPath.row]
        cell.configure(with: character)
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == characters.count - 1 && !isLoading {
            onReachEndOfList?()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource,
              let characterItem = dataSource.itemIdentifier(for: indexPath),
              let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        self.onCharacterSelected?(characterItem, selectedCell)
    }
}

// MARK: - UISearchBarDelegate

extension CharacterListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(performSearch),
            object: nil
        )
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Активируем кнопку Done при начале редактирования
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func performSearch() {
        guard let searchText = searchBar.text else { return }
        onSearch?(searchText)
    }
}
