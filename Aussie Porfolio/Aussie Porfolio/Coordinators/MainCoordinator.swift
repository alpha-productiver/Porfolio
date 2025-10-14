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
        let cashNav = createCashNavigationController()
        let liabilitiesNav = createLiabilitiesNavigationController()
        
        tabBarController.viewControllers = [
            dashboardNav,
            propertiesNav,
            assetsNav,
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
    
    private func createCashNavigationController() -> UINavigationController {
        let cashVC = CashAccountsViewController()
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

        alert.addAction(UIAlertAction(title: "Asset", style: .default) { _ in
            // TODO: Implement showAddAsset()
        })

        alert.addAction(UIAlertAction(title: "Cash Account", style: .default) { _ in
            // TODO: Implement showAddCashAccount()
        })

        alert.addAction(UIAlertAction(title: "Liability", style: .default) { _ in
            // TODO: Implement showAddLiability()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        tabBar.present(alert, animated: true)
    }
}
