//
//  MasterViewController.swift
//  iOSProjectv1
//
//  Created by Stijn Pillaert on 20/12/15.
//  Copyright © 2015 Stijn Pillaert. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MasterViewController: UITableViewController, UISplitViewControllerDelegate, CLLocationManagerDelegate {
    
    enum Error: ErrorType
    {
        case currentLocationNotRetrieved(message: String?)
    }
    
    @IBOutlet var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var publiekeSanitairen: [PubliekSanitair] = []
    var currentTask: NSURLSessionTask?
    var travelMode = "walking"

    override func viewDidLoad() {
        splitViewController!.delegate = self
        setupLocationSettings()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        /* Turn off the default generated constraints. */
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let c1 = NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: tableView, attribute: .CenterX, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: tableView, attribute: .CenterY, multiplier: 1, constant: 0)
        tableView.addSubview(activityIndicator)
        tableView.addConstraints([c1, c2])
        activityIndicator.startAnimating()
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        let c3 = NSLayoutConstraint(item: errorView, attribute: .CenterX, relatedBy: .Equal, toItem: tableView, attribute: .CenterX, multiplier: 1, constant: 0)
        let c4 = NSLayoutConstraint(item: errorView, attribute: .CenterY, relatedBy: .Equal, toItem: tableView, attribute: .CenterY, multiplier: 1, constant: 0)
        let c5 = NSLayoutConstraint(item: errorView, attribute: .Width, relatedBy: .Equal, toItem: tableView, attribute: .Width, multiplier: 1, constant: -16)
        let c6 = NSLayoutConstraint(item: errorView, attribute: .Height, relatedBy: .Equal, toItem: tableView, attribute: .Height, multiplier: 1, constant: 0)
        tableView.addSubview(errorView)
        tableView.addConstraints([c3, c4, c5, c6])
        errorView.hidden = true
        
        /*Lijst met items opvullen
        Eerst worden alle publieke sanitairen afgehaald m.b.v. de 'Service' klasse.
        Daarna wordt de afstand berekend van de huidige locatie van de persoon tot elk sanitair en geordend van dicht naar ver*/
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                self.calculateTravelModeDistances(publiekSanitair)
                self.publiekeSanitairen = publiekSanitair.sort { $0.distanceToUser < $1.distanceToUser }
                self.tableView.reloadData()
                self.errorView.hidden = true
            case .Failure(let error):
                self.errorLabel.text = "\(error)"
                self.errorView.hidden = false
            }
            activityIndicator.stopAnimating()
        }
        currentTask!.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("Deinit")
        currentTask?.cancel()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publiekeSanitairen.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let publiekSanitair = publiekeSanitairen[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = publiekSanitair.situering
        cell.detailTextLabel!.text = "\(publiekSanitair.distanceToUser) km"
        return cell
    }
    
    
    @IBAction func travelByWalking(sender: UIButton) {
        travelMode = "walking"
        calculateTravelModeDistances(publiekeSanitairen)
        self.publiekeSanitairen.sortInPlace { $0.distanceToUser < $1.distanceToUser }
        tableView.reloadData()
    }
    
    
    @IBAction func travelBycar(sender: UIButton) {
        travelMode = "driving"
        calculateTravelModeDistances(publiekeSanitairen)
        self.publiekeSanitairen.sortInPlace { $0.distanceToUser < $1.distanceToUser }
        tableView.reloadData()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        currentTask?.cancel()
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                self.calculateTravelModeDistances(publiekSanitair)
                self.publiekeSanitairen = publiekSanitair.sort { $0.distanceToUser < $1.distanceToUser }
                self.tableView.reloadData()
                self.errorView.hidden = true
            case .Failure(let error):
                self.errorLabel.text = "\(error)"
                self.errorView.hidden = false
            }
            sender.endRefreshing()
        }
        currentTask!.resume()
    }
    
    private func calculateTravelModeDistances(publiekeSanitairen: [PubliekSanitair]) {
        
//      STATISCHE  LOCATIE
//      Om al het onderstaande werk bij 'GESIMULEERDE LOCATIE' te vermijden, kun je best onderstaande code laten staan, indien je toch echt de locatie van het 
//      apparaat wil krijgen moet je het onderstaande lijntje code in commentaar plaatsen
//      Simulated location: coordinates from Kanunnikstraat 44, Gent
        let userLocation = CLLocation(latitude: 51.043232, longitude: 3.722923)
        
//      GESIMULEERDE LOCATIE
//        //Als je de gesimuleerde locatie van de simulator wil gebruiken moet je dit instellen onder 'Debug' -> 'Simulate location'
//        //Omdat de app  je gesimuleerde locatie al wil opvragen, nog voor je de tijd hebt om dit in te stellen moet je de app
//        //in debug-mode runnen en het enige wat je hoeft te doen is het bij het onderstaande lijntje code een break point plaatsen,
//        //de gesimuleerde locatie instellen en daarna mag je de debug-mode weer afleggen
//        let degrees = locationManager.location!.coordinate
//        let userLocation = CLLocation(latitude: (degrees.latitude), longitude: (degrees.longitude))
        
        let distances : [Double]! = DistanceCalculator.calculateDistance(userLocation, sanitairs: publiekeSanitairen, travelMode: travelMode)
        
        //Stelt de afstand in tot elk publiek sanitair op basis van de huidige locatie
        for index in 0...(distances.count-1){
            publiekeSanitairen[index].distanceToUser = distances[index]
        }
    }
    
     func setupLocationSettings(){
        //Geodata
        // Ask for Authorisation from the User
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detail = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        let selectedPubliekSanitair = publiekeSanitairen[tableView.indexPathForSelectedRow!.row]
        detail.publiekSanitair = selectedPubliekSanitair
       let coordinates = locationManager.location?.coordinate
        
        detail.userLocation = Location(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!)
        //detail.userLocation = Location(latitude: 51.043291, longitude: 3.722861)

        if travelMode == "walking"{
            detail.travelMode = "w"
        } else{
            detail.travelMode = "d"
        }
    }
}
