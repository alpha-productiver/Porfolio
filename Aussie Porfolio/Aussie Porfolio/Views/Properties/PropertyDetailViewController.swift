import UIKit

class PropertyDetailViewController: UIViewController {
    var property: Property!
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = property.name
        view.backgroundColor = UIColor.systemGroupedBackground
    }
}