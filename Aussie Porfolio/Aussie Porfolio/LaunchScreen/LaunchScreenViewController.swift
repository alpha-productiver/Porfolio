//
//  LaunchScreenViewController.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 29/9/2025.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    // MARK: - UI Elements
    private let backgroundView = UIView()
    private let logoImageView = UIImageView()
    private let thankYouLabel = UILabel()
    private let productiverLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    private let mainStackView = UIStackView()
    private let textStackView = UIStackView()
    private let loadingStackView = UIStackView()
    
    // MARK: - View Model
    private let viewModel = LaunchScreenViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startLaunchSequence()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = viewModel.appMainBackgroundColor()
        
        setupBackgroundView()
        setupLogoImageView()
        setupTextLabels()
        setupLoadingViews()
        setupStackViews()
    }
    
    private func setupBackgroundView() {
        backgroundView.backgroundColor = viewModel.appMainBackgroundColor()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
    }
    
    private func setupLogoImageView() {
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: viewModel.logoImageName())
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Initial animation state
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        logoImageView.alpha = 0.3
    }
    
    private func setupTextLabels() {
        // Thank you label
        thankYouLabel.text = viewModel.thankYouText
        thankYouLabel.font = viewModel.thankYouFont()
        thankYouLabel.textColor = viewModel.thankYouTextColor()
        thankYouLabel.textAlignment = .center
        thankYouLabel.translatesAutoresizingMaskIntoConstraints = false
        thankYouLabel.alpha = 0
        
        // Productiver label with gradient
        productiverLabel.text = viewModel.productiverText
        productiverLabel.font = viewModel.productiverFont()
        productiverLabel.textAlignment = .center
        productiverLabel.translatesAutoresizingMaskIntoConstraints = false
        productiverLabel.alpha = 0
    }
    
    private func setupLoadingViews() {
        // Loading indicator
        loadingIndicator.color = viewModel.loadingIndicatorColor()
        loadingIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.alpha = 0
        
        // Loading label
        loadingLabel.text = viewModel.loadingText
        loadingLabel.font = viewModel.loadingFont()
        loadingLabel.textColor = viewModel.loadingTextColor()
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.alpha = 0
    }
    
    private func setupStackViews() {
        // Text stack view
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .center
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(thankYouLabel)
        textStackView.addArrangedSubview(productiverLabel)
        
        // Loading stack view
        loadingStackView.axis = .vertical
        loadingStackView.spacing = 12
        loadingStackView.alignment = .center
        loadingStackView.translatesAutoresizingMaskIntoConstraints = false
        loadingStackView.addArrangedSubview(loadingIndicator)
        loadingStackView.addArrangedSubview(loadingLabel)
        
        // Main stack view
        mainStackView.axis = .vertical
        mainStackView.spacing = 40
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add spacer view
        let topSpacerView = UIView()
        mainStackView.addArrangedSubview(topSpacerView)
        mainStackView.addArrangedSubview(logoImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        // Add bottom spacer
        let bottomSpacerView = UIView()
        mainStackView.addArrangedSubview(bottomSpacerView)
        mainStackView.addArrangedSubview(loadingStackView)
        
        // Set spacer priorities
        topSpacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        bottomSpacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        view.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background view
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            // Logo image view
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - View Model Binding
    private func bindViewModel() {
        viewModel.onLogoAnimationStart = { [weak self] in
            self?.animateLogo()
        }
        
        viewModel.onTextAnimationStart = { [weak self] in
            self?.animateText()
        }
        
        viewModel.onLoadingAnimationStart = { [weak self] in
            self?.animateLoading()
        }
        
        viewModel.onLoadingComplete = { [weak self] in
            self?.handleLaunchComplete()
        }
        
        viewModel.onColorSchemeChanged = { [weak self] in
            self?.updateForColorScheme()
        }
    }
    
    // MARK: - Animations
    private func animateLogo() {
        UIView.animate(withDuration: viewModel.logoAnimationDuration, 
                      delay: 0, 
                      options: .curveEaseInOut, 
                      animations: {
            self.logoImageView.transform = CGAffineTransform.identity
            self.logoImageView.alpha = 1.0
        })
    }
    
    private func animateText() {
        applyGradientToLabel(productiverLabel)
        
        UIView.animate(withDuration: viewModel.textAnimationDuration, 
                      delay: 0, 
                      options: .curveEaseInOut, 
                      animations: {
            self.thankYouLabel.alpha = 1.0
            self.productiverLabel.alpha = 1.0
        })
    }
    
    private func animateLoading() {
        UIView.animate(withDuration: viewModel.loadingAnimationDuration, 
                      delay: 0, 
                      options: .curveEaseIn, 
                      animations: {
            self.loadingIndicator.alpha = 1.0
            self.loadingIndicator.startAnimating()
        })
        
        UIView.animate(withDuration: viewModel.loadingAnimationDuration, 
                      delay: 0.2, 
                      options: .curveEaseIn, 
                      animations: {
            self.loadingLabel.alpha = 1.0
        })
    }
    
    private func handleLaunchComplete() {
        // Transition to main app
        transitionToMainApp()
    }
    
    private func transitionToMainApp() {
        // This method will be called when launch is complete
        // You can implement navigation to your main view controller here
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            let mainViewController = ViewController()
            let navigationController = UINavigationController(rootViewController: mainViewController)
            
            UIView.transition(with: window, 
                            duration: 0.5, 
                            options: .transitionCrossDissolve, 
                            animations: {
                window.rootViewController = navigationController
            })
        }
    }
    
    // MARK: - Color Scheme Updates
    private func updateForColorScheme() {
        backgroundView.backgroundColor = viewModel.appMainBackgroundColor()
        view.backgroundColor = viewModel.appMainBackgroundColor()
        logoImageView.image = UIImage(named: viewModel.logoImageName())
        thankYouLabel.textColor = viewModel.thankYouTextColor()
        loadingIndicator.color = viewModel.loadingIndicatorColor()
        applyGradientToLabel(productiverLabel)
    }
    
    private func applyGradientToLabel(_ label: UILabel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = label.bounds
            gradientLayer.colors = self.viewModel.gradientColors()
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            
            // Create a text layer with the gradient
            let textLayer = CATextLayer()
            textLayer.string = label.text
            textLayer.font = label.font
            textLayer.fontSize = label.font.pointSize
            textLayer.frame = label.bounds
            textLayer.alignmentMode = .center
            textLayer.contentsScale = UIScreen.main.scale
            
            gradientLayer.mask = textLayer
            
            // Remove existing gradient layers
            label.layer.sublayers?.removeAll { $0 is CAGradientLayer }
            label.layer.addSublayer(gradientLayer)
            label.textColor = UIColor.clear
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Reapply gradient when layout changes
        applyGradientToLabel(productiverLabel)
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
