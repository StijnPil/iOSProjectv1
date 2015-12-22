

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
    }
    
    

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if !splitViewController!.collapsed {
            navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
        }
    }
    
    
    @IBAction func toonRoute(sender: UIButton) {
            let query = "?saddr=51.043291,3.722861&daddr=\(publiekSanitair.location.latitude),\(publiekSanitair.location.longitude)&dirflg=w"
            let path = "http://maps.apple.com/" + query
            let url = NSURL(string: path)
            UIApplication.sharedApplication().openURL(url!)
    }
}
