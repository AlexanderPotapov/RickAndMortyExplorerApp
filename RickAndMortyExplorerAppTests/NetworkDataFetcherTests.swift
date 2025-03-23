//
//  NetworkDataFetcherTests.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 23.03.2025.
//

import XCTest
@testable import RickAndMortyExplorerApp

final class RickAndMortyDataFetcherTests: XCTestCase {
    
    private var mockNetworkService: MockNetworkService!
    private var dataFetcher: RickAndMortyDataFetcher!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        mockNetworkService = nil
        dataFetcher = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testFetchCharactersSuccess() async throws {
        // Arrange
        let jsonData = TestStubs.successCharacterJSON.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: jsonData)
        
        // Act
        let result = try await dataFetcher.fetchCharacters(page: 1)
        
        // Assert
        XCTAssertEqual(result.info.next, "https://rickandmortyapi.com/api/character?page=2")
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results[0].id, 1)
        XCTAssertEqual(result.results[0].name, "Rick Sanchez")
        XCTAssertEqual(result.results[0].status, .alive)
        
        // Проверьяем правильность URL-адреса, который был вызван
        XCTAssertEqual(mockNetworkService.capturedURL, "https://rickandmortyapi.com/api/character?page=1")
    }
    
    func testFetchCharactersWithNameAndStatus() async throws {
        // Arrange
        let jsonData = TestStubs.emptyResultsJSON.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: jsonData)
        
        // Act
        _ = try await dataFetcher.fetchCharacters(page: 1, name: "Rick", status: .alive)
        
        // Assert - Проверьяем, что URL содержит все параметры
        XCTAssertNotNil(mockNetworkService.capturedURL)
        let capturedURL = mockNetworkService.capturedURL ?? ""
        
        XCTAssertTrue(capturedURL.contains("page=1"), "URL should contain page parameter")
        XCTAssertTrue(capturedURL.contains("name=Rick"), "URL should contain name parameter")
        XCTAssertTrue(capturedURL.contains("status=Alive"), "URL should contain status parameter")
    }
    
    func testFetchCharactersWithEmptyName() async throws {
        // Arrange
        let jsonData = TestStubs.emptyResultsJSON.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: jsonData)
        
        // Act
        _ = try await dataFetcher.fetchCharacters(page: 1, name: "", status: .alive)
        
        // Assert - Проверьяем, что параметр имени не включен, если он пуст
        XCTAssertNotNil(mockNetworkService.capturedURL)
        let capturedURL = mockNetworkService.capturedURL ?? ""
        
        XCTAssertTrue(capturedURL.contains("page=1"), "URL should contain page parameter")
        XCTAssertFalse(capturedURL.contains("name="), "URL should not contain empty name parameter")
        XCTAssertTrue(capturedURL.contains("status=Alive"), "URL should contain status parameter")
    }
    
    // MARK: - Error Tests
    
    func testFetchCharactersNetworkError() async {
        // Arrange
        mockNetworkService.mockError = NetworkError.invalidURL
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch NetworkError.invalidURL {
            // Expected error — тест пройден
        } catch {
            XCTFail("Expected invalidURL error, got \(error)")
        }
    }
    
    func testFetchCharactersBadStatusCode() async {
        // Arrange
        let errorData = TestStubs.apiErrorJSON.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 404, data: errorData)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch NetworkError.badStatusCode(let statusCode) {
            XCTAssertEqual(statusCode, 404, "Status code should be 404")
        } catch {
            XCTFail("Expected badStatusCode error, got \(error)")
        }
    }
    
    func testFetchCharactersNoData() async {
        // Arrange
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: nil)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch NetworkError.noData {
            // Expected error - test passes
        } catch {
            XCTFail("Expected noData error, got \(error)")
        }
    }
    
    func testFetchCharactersDecodingError() async {
        // Arrange
        let invalidData = "Invalid JSON".data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: invalidData)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Expected error — тест пройден
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
}
