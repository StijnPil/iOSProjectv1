import UIKit

class EmptyDetailViewController: UIViewController
{
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        if splitViewController!.displayMode == .PrimaryHidden {
            let target = splitViewController!.displayModeButtonItem().target
            let action = splitViewController!.displayModeButtonItem().action
            target!.performSelector(action)
        }
    }
}