import UIKit

class LiabilitiesViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Liabilities"
        view.backgroundColor = UIColor.systemGroupedBackground
    }
}