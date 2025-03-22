//
//  NetworkDataFetcherTests.swift
//  RickAndMortyExplorerAppTests
//
//  Created by Alexander on 19.03.2025.
//

import XCTest
@testable import RickAndMortyExplorerApp

final class RickAndMortyDataFetcherTests: XCTestCase {
    
    // MARK: - Mocks
    
    class MockNetworkService: NetworkServiceProtocol {
        var mockResponse: NetworkResponse?
        var mockError: Error?
        var capturedURL: String?
        
        func request(with urlString: String) async throws -> NetworkResponse {
            capturedURL = urlString
            
            if let error = mockError {
                throw error
            }
            
            if let response = mockResponse {
                return response
            }
            
            throw NetworkError.unknown
        }
    }
    
    // MARK: - Tests
    
    func testFetchCharactersSuccess() async throws {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        // Создаем JSON-данные напрямую, без кодирования модели
        let jsonString = """
        {
            "info": {
                "next": "https://rickandmortyapi.com/api/character?page=2"
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "type": "",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth",
                        "url": ""
                    },
                    "location": {
                        "name": "Earth",
                        "url": ""
                    },
                    "image": "https://example.com/rick.png",
                    "episode": ["https://rickandmortyapi.com/api/episode/1"],
                    "url": "https://rickandmortyapi.com/api/character/1",
                    "created": "2017-11-04T18:48:46.250Z"
                }
            ]
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: jsonData)
        
        // Act
        let result = try await dataFetcher.fetchCharacters(page: 1)
        
        // Assert
        XCTAssertEqual(result.info.next, "https://rickandmortyapi.com/api/character?page=2")
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results[0].id, 1)
        XCTAssertEqual(result.results[0].name, "Rick Sanchez")
        XCTAssertEqual(result.results[0].status, .alive)
        
        // Проверяем URL
        XCTAssertEqual(mockNetworkService.capturedURL, "https://rickandmortyapi.com/api/character?page=1")
    }
    
    func testFetchCharactersWithNameAndStatus() async throws {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        // Создаем JSON-данные напрямую
        let jsonString = """
        {
            "info": {
                "next": null
            },
            "results": []
        }
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: jsonData)
        
        // Act
        _ = try await dataFetcher.fetchCharacters(page: 1, name: "Rick", status: .alive)
        
        // Assert
        // Проверяем, что URL содержит нужные параметры
        XCTAssertTrue(mockNetworkService.capturedURL?.contains("page=1") ?? false)
        XCTAssertTrue(mockNetworkService.capturedURL?.contains("name=Rick") ?? false)
        XCTAssertTrue(mockNetworkService.capturedURL?.contains("status=Alive") ?? false)
    }
    
    func testFetchCharactersNetworkError() async {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        mockNetworkService.mockError = NetworkError.invalidURL
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            // Проверяем тип ошибки с помощью switch вместо XCTAssertEqual
            switch error {
            case .invalidURL:
                // Это ожидаемая ошибка
                break
            default:
                XCTFail("Expected invalidURL error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
    
    func testFetchCharactersBadStatusCode() async {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 404, data: nil)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            switch error {
            case .badStatusCode(let statusCode):
                XCTAssertEqual(statusCode, 404)
            default:
                XCTFail("Expected badStatusCode error")
            }
        } catch {
            XCTFail("Expected NetworkError")
        }
    }
    
    func testFetchCharactersNoData() async {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: nil)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            // Проверяем тип ошибки с помощью switch
            switch error {
            case .noData:
                // Это ожидаемая ошибка
                break
            default:
                XCTFail("Expected noData error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(error)")
        }
    }
    
    func testFetchCharactersDecodingError() async {
        // Arrange
        let mockNetworkService = MockNetworkService()
        let dataFetcher = RickAndMortyDataFetcher(networkService: mockNetworkService)
        
        // Неверные данные для декодирования
        let invalidData = "Invalid JSON".data(using: .utf8)!
        mockNetworkService.mockResponse = NetworkResponse(statusCode: 200, data: invalidData)
        
        // Act & Assert
        do {
            _ = try await dataFetcher.fetchCharacters(page: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            switch error {
            case .decodingError:
                // Ожидаемая ошибка
                break
            default:
                XCTFail("Expected decodingError")
            }
        } catch {
            XCTFail("Expected NetworkError")
        }
    }
}

