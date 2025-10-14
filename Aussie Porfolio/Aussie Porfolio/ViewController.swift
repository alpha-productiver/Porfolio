//
//  ViewController.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 29/9/2025.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: MainViewModel!
    // MARK: - UI Elements
    private let welcomeLabel = UILabel()
    private let descriptionLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupViewModel() {
        viewModel = MainViewModel()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = viewModel.backgroundColor()
        
        // Welcome label
        welcomeLabel.text = viewModel.welcomeText
        welcomeLabel.font = viewModel.welcomeFont()
        welcomeLabel.textColor = viewModel.primaryTextColor()
        welcomeLabel.textAlignment = .center
        welcomeLabel.numberOfLines = 0
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        // Description label
        descriptionLabel.text = viewModel.descriptionText
        descriptionLabel.font = viewModel.descriptionFont()
        descriptionLabel.textColor = viewModel.secondaryTextColor()
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            welcomeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onColorSchemeChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.updateForColorScheme()
            }
        }
    }
    
    private func updateForColorScheme() {
        view.backgroundColor = viewModel.backgroundColor()
        welcomeLabel.textColor = viewModel.primaryTextColor()
        descriptionLabel.textColor = viewModel.secondaryTextColor()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                viewModel.updateColorScheme(traitCollection)
            }
        }
    }
}

