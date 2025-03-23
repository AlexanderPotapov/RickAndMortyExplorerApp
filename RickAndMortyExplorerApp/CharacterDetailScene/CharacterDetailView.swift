//
//  CharacterDetailView.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import SwiftUI

struct CharacterDetailView<ViewModel: CharacterDetailViewModelProtocol>: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                CharacterImageView(
                    image: viewModel.characterImage,
                    isLoading: viewModel.isLoading
                )
                
                CharacterHeaderView(
                    status: viewModel.detailItem.status,
                    statusColor: viewModel.detailItem.statusColor
                )
                
                CharacterInfoView(
                    species: viewModel.detailItem.species,
                    gender: viewModel.detailItem.gender,
                    origin: viewModel.detailItem.origin,
                    location: viewModel.detailItem.location
                )
                
                if !viewModel.detailItem.episodes.isEmpty {
                    EpisodesListView(episodes: viewModel.detailItem.episodes)
                }
            }
            .padding()
        }
        .task {
            await viewModel.loadImage()
        }
        .alert(item: alertItem) { item in
            Alert(
                title: Text("Ошибка"),
                message: Text(item.id),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Alert Helper
    
    private var alertItem: Binding<IdentifiableString?> {
        Binding<IdentifiableString?>(
            get: { viewModel.errorMessage.map { IdentifiableString(id: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}

// MARK: - Helper Structs

struct IdentifiableString: Identifiable {
    let id: String
}

// MARK: - Character Image View

struct CharacterImageView: View {
    let image: UIImage?
    let isLoading: Bool
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(radius: 5)
        } else if isLoading {
            ProgressView()
                .frame(width: 200, height: 200)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Character Header View

struct CharacterHeaderView: View {
    let status: String
    let statusColor: UIColor
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(statusColor))
                .frame(width: 10, height: 10)
            Text(status)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Character Info View

struct CharacterInfoView: View {
    let species: String
    let gender: String
    let origin: String
    let location: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(label: "Вид:", value: species)
            infoRow(label: "Пол:", value: gender)
            infoRow(label: "Происхождение:", value: origin)
            infoRow(label: "Местоположение:", value: location)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            Text(value)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Episodes List View

struct EpisodesListView: View {
    let episodes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Эпизоды")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(episodes, id: \.self) { episode in
                        EpisodeItemView(title: episode)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Episode Item View

struct EpisodeItemView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
    }
}
