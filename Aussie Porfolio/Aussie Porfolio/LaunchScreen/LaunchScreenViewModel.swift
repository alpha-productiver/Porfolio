//
//  LaunchScreenViewModel.swift
//  Aussie Porfolio
//
//  Created by Zibo Lin on 29/9/2025.
//

import UIKit

class LaunchScreenViewModel {

    // MARK: - Properties
    private var currentTraitCollection: UITraitCollection?

    // MARK: - Text Content
    let thankYouText = "Thank you for being"
    let productiverText = "a productiver today"
    let loadingText = "Loading your tasks..."
    
    // MARK: - Animation Durations
    let logoAnimationDuration: TimeInterval = 1.0
    let textAnimationDuration: TimeInterval = 1.0
    let loadingAnimationDuration: TimeInterval = 0.5
    
    // MARK: - Animation Delays
    let textAnimationDelay: TimeInterval = 0.5
    let loadingAnimationDelay: TimeInterval = 0.5
    let loadingTextDelay: TimeInterval = 0.2
    
    // MARK: - Completion Handler
    let totalLaunchDuration: TimeInterval = 3.0
    
    // MARK: - Callbacks
    var onLogoAnimationStart: (() -> Void)?
    var onTextAnimationStart: (() -> Void)?
    var onLoadingAnimationStart: (() -> Void)?
    var onLoadingComplete: (() -> Void)?
    var onColorSchemeChanged: (() -> Void)?
    
    // MARK: - Initialization
    init() {
        if #available(iOS 13.0, *) {
            currentTraitCollection = UIScreen.main.traitCollection
        }
    }
    
    // MARK: - Launch Sequence
    func startLaunchSequence() {
        // Start logo animation immediately
        onLogoAnimationStart?()
        
        // Start text animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + textAnimationDelay) {
            self.onTextAnimationStart?()
        }
        
        // Start loading animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingAnimationDelay) {
            self.onLoadingAnimationStart?()
        }
        
        // Complete launch after total duration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalLaunchDuration) {
            self.onLoadingComplete?()
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
    func logoImageName() -> String {
        return isDarkMode() ? "darkmode" : "individual logo"
    }
    
    func appMainBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
            }
        } else {
            return UIColor.white
        }
    }
    
    func thankYouFont() -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: 20, weight: .light)
        if #available(iOS 13.0, *) {
            return UIFont(descriptor: baseFont.fontDescriptor.withDesign(.serif) ?? baseFont.fontDescriptor, size: 20)
        }
        return baseFont
    }
    
    func productiverFont() -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        if #available(iOS 13.0, *) {
            return UIFont(descriptor: baseFont.fontDescriptor.withDesign(.serif) ?? baseFont.fontDescriptor, size: 24)
        }
        return baseFont
    }
    
    func loadingFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    func thankYouTextColor() -> UIColor {
        return isDarkMode() ? UIColor.white.withAlphaComponent(0.7) : UIColor.black.withAlphaComponent(0.6)
    }
    
    func loadingTextColor() -> UIColor {
        return UIColor.gray
    }
    
    func loadingIndicatorColor() -> UIColor {
        return isDarkMode() ? .white : .black
    }
    
    func gradientColors() -> [CGColor] {
        if isDarkMode() {
            return [
                UIColor(red: 0.68, green: 0.47, blue: 0.96, alpha: 1.0).cgColor,
                UIColor(red: 0.47, green: 0.68, blue: 0.96, alpha: 1.0).cgColor
            ]
        } else {
            return [
                UIColor(red: 0.96, green: 0.47, blue: 0.47, alpha: 1.0).cgColor,
                UIColor(red: 0.96, green: 0.68, blue: 0.47, alpha: 1.0).cgColor
            ]
        }
    }
}
