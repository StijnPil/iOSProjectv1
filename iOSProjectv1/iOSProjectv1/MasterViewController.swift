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
        Eerst worden alle publieke sanitairen afgehaald via m.b.v. de 'Service' klasse.
        Daarna wordt de STD (straight line distance = vogelvlucht) berekend tussen de huidige plaats van de gebruiker en het publiek sanitair.
        Daarna wordt van de 20 dichtste STD sanitairen de werkelijke afstand berekend op basis van de travelMode (te voet / auto) 
        De reden dat dit ik eerst de STD bereken en daarna pas de werkelijke afstand is omdat als ik voor alle sanitairen direct hun werkelijke afstand
        wil berekenen dit te veel requests zijn en de applicatie traag werkt.'
        Als ik voor alle sanitairen */
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
//                let STDpubliekeSanitairen = publiekSanitair.sort { self.sortByStraightLineDistance($0.location) < self.sortByStraightLineDistance($1.location) }
//                let xNearestSanitairen = self.getXNearestSanitairen(20, sanitairen: STDpubliekeSanitairen)
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
//                let STDpubliekeSanitairen = publiekSanitair.sort { self.sortByStraightLineDistance($0.location) < self.sortByStraightLineDistance($1.location) }
//                let nearest20Sanitairen = self.getXNearestSanitairen(20, sanitairen: STDpubliekeSanitairen)
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
    
    private func sortByStraightLineDistance(location: Location) -> Double{
        //        //real actual location, but not working in simulator because current location in simulator is an Apple Store in California)
        //        let coordinates = locationManager.location?.coordinate
        //        let location1 = CLLocation(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!)
        
        let location1 = CLLocation(latitude: 51.043291, longitude: 3.722861)
        let location2 = CLLocation(latitude: location.latitude, longitude: location.longitude)
        //Deel de afstand in meters door duizend en afronden op 1 decimaal na de komma
        let distance =  (Double(round(10*(location2.distanceFromLocation(location1))/1000)/10))
        return distance
    }
    
    private func calculateTravelModeDistances(publiekeSanitairen: [PubliekSanitair]) {
//        //real actual location, but not working in simulator because current location in simulator is an Apple Store in California)
//        let degrees = locationManager.location!.coordinate
//        let userLocation = CLLocation(latitude: (degrees.latitude), longitude: (degrees.longitude))
        let userLocation = CLLocation(latitude: 51.043291, longitude: 3.722861)

        let distances : [Double]! = DistanceCalculator.calculateDistance(userLocation, sanitairs: publiekeSanitairen, travelMode: travelMode)
        print(distances.count)
        print(publiekeSanitairen.count)
        
        for index in 0...(distances.count-1){
            publiekeSanitairen[index].distanceToUser = distances[index]
        }
    }
    
    private func getXNearestSanitairen(x: Int, sanitairen: [PubliekSanitair]) -> [PubliekSanitair]{
        var xSanitairen : [PubliekSanitair]! = []
        for index in 0...(x-1){
            xSanitairen.append(sanitairen[index])
        }
        return xSanitairen
    }
    
     func setupLocationSettings(){
        //Geodata
        // Ask for Authorisation from the User
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
    }
}
