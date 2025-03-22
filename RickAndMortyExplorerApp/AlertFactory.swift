//
//  AlertFactory.swift
//  RickAndMortyExplorerApp
//
//  Created by Alexander on 22.03.2025.
//

import UIKit

// MARK: - AlertFactoryProtocol

protocol AlertFactoryProtocol {
    func makeAlert(title: String, message: String) -> UIViewController
}

// MARK: - AlertFactory

final class AlertFactory: AlertFactoryProtocol {
    func makeAlert(title: String, message: String) -> UIViewController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
