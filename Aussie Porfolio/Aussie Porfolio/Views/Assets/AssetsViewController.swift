import UIKit

class AssetsViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assets"
        view.backgroundColor = UIColor.systemGroupedBackground
    }
}