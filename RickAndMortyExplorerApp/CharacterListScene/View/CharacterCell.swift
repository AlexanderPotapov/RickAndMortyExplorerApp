//
//  CharacterCell.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import Foundation
import SDWebImage

final class CharacterCell: UITableViewCell {
    
    static let reuseIdentifier = "CharacterCell"
    
    // MARK: - Properties
    
    private var statusColor: UIColor?
    
    // MARK: - UI Components
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let backgroundColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        characterImageView.sd_cancelCurrentImageLoad()
        characterImageView.image = nil
        nameLabel.text = nil
        speciesLabel.text = nil
        backgroundColorView.backgroundColor = .systemBackground
        statusColor = nil
    }
    
    // MARK: - Configuration
    
    func configure(with item: CharacterListItem) {
        nameLabel.text = item.name
        speciesLabel.text = "\(item.species) - \(item.status)"
        
        // Загружаем изображение с помощью SDWebImage
        if let imageURL = URL(string: item.imageUrl) {
            characterImageView.sd_setImage(
                with: imageURL,
                placeholderImage: UIImage(systemName: "person.circle"),
                options: [.retryFailed, .refreshCached],
                completed: nil
            )
        }
        
        // Сохраняем цвет статуса
        statusColor = item.statusColor
        
        // Устанавливаем цвет фона ячейки в зависимости от статуса
        let backgroundColor = item.statusColor.withAlphaComponent(0.2)
        backgroundColorView.backgroundColor = backgroundColor
    }
    
    // MARK: - Private Methods
    private func commonInit() {
        // Настраиваем внешний вид ячейки
        selectionStyle = .none
        backgroundColor = .clear
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        
        // Добавляем фоновую вью
        contentView.addSubview(backgroundColorView)
        
        // Добавляем остальные элементы поверх фоновой вью
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(speciesLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Фоновая вью занимает почти всю ячейку с отступами
            backgroundColorView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            backgroundColorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 8
            ),
            backgroundColorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -8
            ),
            backgroundColorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4
            ),
            
            characterImageView.leadingAnchor.constraint(
                equalTo: backgroundColorView.leadingAnchor,
                constant: 8
            ),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            characterImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(
                equalTo: characterImageView.trailingAnchor,
                constant: 16
            ),
            nameLabel.topAnchor.constraint(
                equalTo: backgroundColorView.topAnchor,
                constant: 12
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: backgroundColorView.trailingAnchor,
                constant: -16
            ),
            
            speciesLabel.leadingAnchor.constraint(
                equalTo: characterImageView.trailingAnchor,
                constant: 16
            ),
            speciesLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 4
            ),
            speciesLabel.trailingAnchor.constraint(
                equalTo: backgroundColorView.trailingAnchor,
                constant: -16
            ),
            speciesLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: backgroundColorView.bottomAnchor,
                constant: -12
            )
        ])
        
        // Устанавливаем минимальную высоту ячейки
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
    }
}
