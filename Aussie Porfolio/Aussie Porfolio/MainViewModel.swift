//
//  MainViewModel.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 29/9/2025.
//

import UIKit

class MainViewModel {
    
    // MARK: - Properties
    private var currentTraitCollection: UITraitCollection?

    // MARK: - Text Content
    let welcomeText = "Welcome to Aussie Portfolio"
    let descriptionText = "Your productivity journey continues here!"
    
    // MARK: - Callbacks
    var onColorSchemeChanged: (() -> Void)?
    
    // MARK: - Initialization
    init() {
        if #available(iOS 13.0, *) {
            currentTraitCollection = UIScreen.main.traitCollection
        }
    }

    // MARK: - Color Scheme Management
    func updateColorScheme(_ traitCollection: UITraitCollection) {
        currentTraitCollection = traitCollection
        onColorSchemeChanged?()
    }
    
    private func isDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            return currentTraitCollection?.userInterfaceStyle == .dark
        }
        return false
    }
    
    // MARK: - UI Configuration
    func backgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
            }
        } else {
            return UIColor.white
        }
    }
    
    func welcomeFont() -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        if #available(iOS 13.0, *) {
            return UIFont(descriptor: baseFont.fontDescriptor.withDesign(.rounded) ?? baseFont.fontDescriptor, size: 28)
        }
        return baseFont
    }
    
    func descriptionFont() -> UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
    func primaryTextColor() -> UIColor {
        return isDarkMode() ? UIColor.white : UIColor.black
    }
    
    func secondaryTextColor() -> UIColor {
        return isDarkMode() ? UIColor.white.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.7)
    }
}
