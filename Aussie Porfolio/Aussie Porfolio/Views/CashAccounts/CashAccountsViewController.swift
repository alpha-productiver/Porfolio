import UIKit

class CashAccountsViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cash Accounts"
        view.backgroundColor = UIColor.systemGroupedBackground
    }
}