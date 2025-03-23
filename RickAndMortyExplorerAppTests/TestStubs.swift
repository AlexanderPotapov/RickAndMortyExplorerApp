//
//  TestStubs.swift
//  RickAndMortyExplorerAppTests
//
//  Created by Alexander on 23.03.2025.
//

import Foundation

enum TestStubs {
    static let successCharacterJSON = """
    {
        "info": {
            "count": 826,
            "pages": 42,
            "next": "https://rickandmortyapi.com/api/character?page=2",
            "prev": null
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
                    "url": "https://rickandmortyapi.com/api/location/1"
                },
                "location": {
                    "name": "Earth",
                    "url": "https://rickandmortyapi.com/api/location/20"
                },
                "image": "https://example.com/rick.png",
                "episode": ["https://rickandmortyapi.com/api/episode/1"],
                "url": "https://rickandmortyapi.com/api/character/1",
                "created": "2017-11-04T18:48:46.250Z"
            }
        ]
    }
    """
    
    static let emptyResultsJSON = """
    {
        "info": {
            "count": 0,
            "pages": 0,
            "next": null,
            "prev": null
        },
        "results": []
    }
    """
    
    static let apiErrorJSON = """
    {
        "error": "There is nothing here"
    }
    """
}
