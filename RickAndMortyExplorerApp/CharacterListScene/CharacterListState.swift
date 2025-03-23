//
//  CharacterListState.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import Foundation

struct CharacterListState {
    var characters: [Character] = []
    
    // Пагинация
    var currentPage: Int = 1
    var hasNextPage: Bool = true
    var isLoading: Bool = false
    
    // Поиск и фильтрация
    var searchQuery: String = ""
    var statusFilter: Status?
    
    var isSearchActive: Bool {
        return !searchQuery.isEmpty
    }
    
    // Методы изменения состояния
    mutating func resetPagination() {
        currentPage = 1
        hasNextPage = true
        characters.removeAll()
    }
    
    mutating func appendCharacters(_ newCharacters: [Character]) {
        characters.append(contentsOf: newCharacters)
        currentPage += 1
    }
    
    mutating func updateSearchQuery(_ query: String) {
        // Если поисковый запрос изменился, сбрасываем пагинацию
        if query != searchQuery {
            resetPagination()
        }
        searchQuery = query
    }
    
    mutating func updateStatusFilter(_ status: Status?) {
        statusFilter = status
        resetPagination()
    }
    
    mutating func resetSearch() {
        if !searchQuery.isEmpty {
            searchQuery = ""
            resetPagination()
        }
    }
    
    mutating func resetFilters() {
        if statusFilter != nil {
            statusFilter = nil
            resetPagination()
        }
    }
}
