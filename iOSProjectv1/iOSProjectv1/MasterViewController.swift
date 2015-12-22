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
    
    let locationManager = CLLocationManager()
    var publiekeSanitairen: [PubliekSanitair] = []
    var currentTask: NSURLSessionTask?

    override func viewDidLoad() {
        splitViewController!.delegate = self        

        
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

        //Lijst met items opvullen
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                self.publiekeSanitairen = publiekSanitair.sort { self.sortByDistance($0.location) < self.sortByDistance($1.location) }
                self.tableView.reloadData()
                self.errorView.hidden = true
            case .Failure(let error):
                self.errorLabel.text = "\(error)"
                self.errorView.hidden = false
            }
            activityIndicator.stopAnimating()
        }
        currentTask!.resume()
            setupLocationSettings()
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        currentTask?.cancel()
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                self.publiekeSanitairen = publiekSanitair.sort { self.sortByDistance($0.location) < self.sortByDistance($1.location) }
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
    
    private func sortByDistance(location: Location) -> Double{
        //        //real actual location, but not working in simulator because current location in simulator is an Apple Store in California)
        //        let coordinates = locationManager.location?.coordinate
        //        let location1 = CLLocation(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!)
        
        let location1 = CLLocation(latitude: 51.043291, longitude: 3.722861)
        let location2 = CLLocation(latitude: location.latitude, longitude: location.longitude)
        //Deel de afstand in meters door duizend en afronden op 1 decimaal na de komma
        return (Double(round(10*(location2.distanceFromLocation(location1))/1000)/10))
    }
    
    private func setupLocationSettings(){
        //Geodata
        // Ask for Authorisation from the User.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        cell.detailTextLabel!.text = "\(sortByDistance(publiekSanitair.location)) km"
        return cell
    }
    
    deinit {
        print("Deinit")
        currentTask?.cancel()
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
