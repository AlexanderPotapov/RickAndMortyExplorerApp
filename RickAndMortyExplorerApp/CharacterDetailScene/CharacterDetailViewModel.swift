//
//  CharacterDetailViewModel.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import UIKit
import SDWebImage

// MARK: - Protocol

protocol CharacterDetailViewModelProtocol: ObservableObject {
    var detailItem: CharacterDetailItem { get }
    var characterImage: UIImage? { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    
    func loadImage() async
}

// MARK: - CharacterDetailViewModel

final class CharacterDetailViewModel: ObservableObject, CharacterDetailViewModelProtocol {
    // MARK: - Published Properties
    
    @Published private(set) var detailItem: CharacterDetailItem
    @Published var characterImage: UIImage?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let character: Character
    
    // MARK: - Initialization
    
    init(character: Character) {
        self.character = character
        self.detailItem = CharacterDetailViewModel.createDetailItem(from: character)
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadImage() async {
        guard let imageUrl = URL(string: detailItem.imageUrl) else {
            self.errorMessage = "Некорректный URL изображения"
            return
        }
        
        self.isLoading = true
        
        do {
            let image = try await downloadImage(from: imageUrl)
            self.characterImage = image
        } catch {
            // Устанавливаем сообщение об ошибке без проверки на отмену задачи
            self.errorMessage = "Ошибка загрузки изображения: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    // MARK: - Private Methods
    
    private static func createDetailItem(from character: Character) -> CharacterDetailItem {
        let statusColor: UIColor
        switch character.status {
        case .alive: statusColor = .systemGreen
        case .dead: statusColor = .systemRed
        case .unknown: statusColor = .systemGray
        }
        
        let episodes = character.episode.compactMap { url -> String? in
            guard let lastComponent = url.split(separator: "/").last else { return nil }
            return "Эпизод \(lastComponent)"
        }
        
        return CharacterDetailItem(
            id: character.id,
            name: character.name,
            statusColor: statusColor,
            status: character.status.rawValue,
            species: character.species,
            gender: character.gender,
            origin: character.origin.name,
            location: character.location.name,
            imageUrl: character.image,
            episodes: episodes
        )
    }
    
    // Вспомогательный метод для загрузки изображения с использованием async/await
    private func downloadImage(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            
            SDWebImageManager.shared.loadImage(
                with: url,
                options: [.highPriority, .retryFailed],
                progress: nil,
                completed: { image, _, error, _, _, _ in
                    
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let image = image {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(
                            throwing: NSError(
                                domain: "ImageDownloadError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить изображение"]
                            )
                        )
                    }
                }
            )
        }
    }
}
