import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let window: UIWindow
    private let realmService: RealmService
    private weak var tabBarController: UITabBarController?

    private enum TabIndex {
        static let dashboard = 0
        static let cashFlow = 1
        static let properties = 2
        static let more = 3
    }

    init(window: UIWindow, navigationController: UINavigationController = UINavigationController()) {
        self.window = window
        self.navigationController = navigationController
        self.realmService = RealmService.shared
    }
    
    func start() {
        setupNavigationBar()
        showDashboard()

        let tabBar = createTabBarController()
        self.tabBarController = tabBar
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
    
    private func setupNavigationBar() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .systemGreen
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let dashboardNav = createDashboardNavigationController()
        let cashFlowNav = createCashFlowNavigationController()
        let propertiesNav = createPropertiesNavigationController()
        let moreNav = createMoreNavigationController()

        tabBarController.viewControllers = [
            dashboardNav,
            cashFlowNav,
            propertiesNav,
            moreNav
        ]
        tabBarController.customizableViewControllers = tabBarController.viewControllers

        tabBarController.tabBar.tintColor = .systemGreen
        
        return tabBarController
    }
    
    private func createDashboardNavigationController() -> UINavigationController {
        let dashboardVC = DashboardViewController()
        let viewModel = DashboardViewModel(realmService: realmService)
        dashboardVC.viewModel = viewModel
        dashboardVC.coordinator = self
        
        let navController = UINavigationController(rootViewController: dashboardVC)
        navController.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "chart.pie"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    private func createPropertiesNavigationController() -> UINavigationController {
        let propertiesVC = PropertiesViewController()
        let viewModel = PropertyViewModel(realmService: realmService)
        propertiesVC.viewModel = viewModel
        propertiesVC.coordinator = self
        
        let navController = UINavigationController(rootViewController: propertiesVC)
        navController.tabBarItem = UITabBarItem(
            title: "Properties",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    private func createCashFlowNavigationController() -> UINavigationController {
        let cashFlowVC = CashFlowViewController()
        let viewModel = CashFlowViewModel(realmService: realmService)
        cashFlowVC.viewModel = viewModel
        cashFlowVC.coordinator = self

        let navController = UINavigationController(rootViewController: cashFlowVC)
        navController.tabBarItem = UITabBarItem(
            title: "Cash Flow",
            image: UIImage(systemName: "waveform.path.ecg"),
            selectedImage: UIImage(systemName: "waveform.path.ecg")
        )
        navController.navigationBar.prefersLargeTitles = true

        return navController
    }

    private func createMoreNavigationController() -> UINavigationController {
        let moreVC = MoreViewController()
        moreVC.coordinator = self

        let navController = UINavigationController(rootViewController: moreVC)
        navController.tabBarItem = UITabBarItem(
            title: "More",
            image: UIImage(systemName: "ellipsis.circle"),
            selectedImage: UIImage(systemName: "ellipsis.circle.fill")
        )
        navController.navigationBar.prefersLargeTitles = true

        return navController
    }
    
    private func createLiabilitiesNavigationController() -> UINavigationController {
        let liabilitiesVC = LiabilitiesViewController()
        let viewModel = LiabilityViewModel()
        liabilitiesVC.viewModel = viewModel
        liabilitiesVC.coordinator = self

        let navController = UINavigationController(rootViewController: liabilitiesVC)
        navController.tabBarItem = UITabBarItem(
            title: "Liabilities",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        navController.navigationBar.prefersLargeTitles = true

        return navController
    }
    
    private func showDashboard() {
        let dashboardVC = DashboardViewController()
        let viewModel = DashboardViewModel(realmService: realmService)
        dashboardVC.viewModel = viewModel
        dashboardVC.coordinator = self
        navigationController.pushViewController(dashboardVC, animated: false)
    }
    
    func showPropertyDetail(_ property: Property) {
        let vm = PropertyViewModel(realmService: realmService)
        let vc = AddPropertyViewController(viewModel: vm, propertyToEdit: property)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium // Background stays dimmed
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showAddProperty() {
        let vm = PropertyViewModel(realmService: realmService)
        let vc = AddPropertyViewController(viewModel: vm)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium // Background stays dimmed
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showAssetDetail(_ asset: Asset) {
        let vm = AssetViewModel()
        let vc = AddAssetViewController(viewModel: vm, assetToEdit: asset)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showAddAsset() {
        let vm = AssetViewModel()
        let vc = AddAssetViewController(viewModel: vm)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showCashAccountDetail(_ account: CashAccount) {
        let vm = CashAccountViewModel()
        let vc = AddCashAccountViewController(viewModel: vm, accountToEdit: account)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showAddCashAccount() {
        let vm = CashAccountViewModel()
        let vc = AddCashAccountViewController(viewModel: vm)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showLiabilityDetail(_ liability: Liability) {
        let vm = LiabilityViewModel()
        let vc = AddLiabilityViewController(viewModel: vm, liabilityToEdit: liability)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    func showAddLiability() {
        let vm = LiabilityViewModel()
        let vc = AddLiabilityViewController(viewModel: vm)
        vc.coordinator = self

        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        } else {
            nav.modalPresentationStyle = .formSheet
        }
        tabBarController?.present(nav, animated: true)
    }

    // MARK: - Tab Navigation

    func showProperties() {
        tabBarController?.selectedIndex = TabIndex.properties
    }

    func showAssets() {
        guard let tabBarController else { return }
        tabBarController.selectedIndex = TabIndex.more

        guard let nav = tabBarController.viewControllers?[TabIndex.more] as? UINavigationController else { return }
        nav.popToRootViewController(animated: false)

        let assetsVC = AssetsViewController()
        let viewModel = AssetViewModel()
        assetsVC.viewModel = viewModel
        assetsVC.coordinator = self
        nav.pushViewController(assetsVC, animated: true)
    }

    func showCash() {
        guard let tabBarController else { return }
        tabBarController.selectedIndex = TabIndex.more

        guard let nav = tabBarController.viewControllers?[TabIndex.more] as? UINavigationController else { return }
        nav.popToRootViewController(animated: false)

        let cashVC = CashAccountsViewController()
        let viewModel = CashAccountViewModel()
        cashVC.viewModel = viewModel
        cashVC.coordinator = self
        nav.pushViewController(cashVC, animated: true)
    }

    func showLiabilities() {
        guard let tabBarController else { return }
        tabBarController.selectedIndex = TabIndex.more

        guard let nav = tabBarController.viewControllers?[TabIndex.more] as? UINavigationController else { return }
        nav.popToRootViewController(animated: false)

        let liabilitiesVC = LiabilitiesViewController()
        let viewModel = LiabilityViewModel()
        liabilitiesVC.viewModel = viewModel
        liabilitiesVC.coordinator = self
        nav.pushViewController(liabilitiesVC, animated: true)
    }

    func startAddFlow() {
        // Show action sheet to choose what to add
        guard let tabBar = tabBarController else { return }

        let alert = UIAlertController(title: "Add New", message: "What would you like to add?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Property", style: .default) { [weak self] _ in
            self?.showAddProperty()
        })

        alert.addAction(UIAlertAction(title: "Asset", style: .default) { [weak self] _ in
            self?.showAddAsset()
        })

        alert.addAction(UIAlertAction(title: "Cash Account", style: .default) { [weak self] _ in
            self?.showAddCashAccount()
        })

        alert.addAction(UIAlertAction(title: "Liability", style: .default) { [weak self] _ in
            self?.showAddLiability()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        tabBar.present(alert, animated: true)
    }
}
