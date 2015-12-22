

import UIKit
import MapKit

class DetailViewController: UITableViewController {
    
    @IBOutlet weak var type_sanit: UILabel!
    @IBOutlet weak var type_loc: UILabel!
    @IBOutlet weak var prijs_toeg: UILabel!
    @IBOutlet weak var open7op7da: UILabel!
    @IBOutlet weak var openuren: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var publiekSanitair: PubliekSanitair!
    
    override func viewDidLoad() {
        //super.viewDidLoad()

        // Do any additional setup after loading the view.
        type_sanit.text = "Type: \(publiekSanitair.type_sanit)"
        type_loc.text = "Locatie: \(publiekSanitair.type_locat)"
        prijs_toeg.text = "Prijs: \(publiekSanitair.prijs_toeg)"
        open7op7da.text = "Elke dag open: \(publiekSanitair.open7op7da)"
        openuren.text = "Openingsuren: \(publiekSanitair.openuren)"
        
        let cllocationmanager = CLLocationManager()
        cllocationmanager.requestAlwaysAuthorization()
        
        let center = CLLocationCoordinate2D(latitude: publiekSanitair.location.latitude, longitude: publiekSanitair.location.longitude)
        let visibleRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.region = visibleRegion
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if !splitViewController!.collapsed {
            navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
