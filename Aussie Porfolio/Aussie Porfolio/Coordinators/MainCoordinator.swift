import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let window: UIWindow
    private let realmService: RealmService
    private weak var tabBarController: UITabBarController?

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
        let propertiesNav = createPropertiesNavigationController()
        let assetsNav = createAssetsNavigationController()
        let cashFlowNav = createCashFlowNavigationController()
        let cashNav = createCashNavigationController()
        let liabilitiesNav = createLiabilitiesNavigationController()

        tabBarController.viewControllers = [
            dashboardNav,
            propertiesNav,
            assetsNav,
            cashFlowNav,
            cashNav,
            liabilitiesNav
        ]
        
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
    
    private func createAssetsNavigationController() -> UINavigationController {
        let assetsVC = AssetsViewController()
        let viewModel = AssetViewModel()
        assetsVC.viewModel = viewModel
        assetsVC.coordinator = self

        let navController = UINavigationController(rootViewController: assetsVC)
        navController.tabBarItem = UITabBarItem(
            title: "Assets",
            image: UIImage(systemName: "dollarsign.circle"),
            selectedImage: UIImage(systemName: "dollarsign.circle.fill")
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

    private func createCashNavigationController() -> UINavigationController {
        let cashVC = CashAccountsViewController()
        let viewModel = CashAccountViewModel()
        cashVC.viewModel = viewModel
        cashVC.coordinator = self

        let navController = UINavigationController(rootViewController: cashVC)
        navController.tabBarItem = UITabBarItem(
            title: "Cash",
            image: UIImage(systemName: "banknote"),
            selectedImage: UIImage(systemName: "banknote.fill")
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
        tabBarController?.selectedIndex = 1
    }

    func showAssets() {
        tabBarController?.selectedIndex = 2
    }

    func showCash() {
        tabBarController?.selectedIndex = 3
    }

    func showLiabilities() {
        tabBarController?.selectedIndex = 4
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
