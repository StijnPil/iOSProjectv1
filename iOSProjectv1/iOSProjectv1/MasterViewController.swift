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
    var publiekSanitair: [PubliekSanitair] = []
    var currentTask: NSURLSessionTask?

    override func viewDidLoad() {
        //Niet meer aanroepen omdat 'UISplitViewControllerDelegate' geïmplement wordt, vervangede regel staat er onder
        //super.viewDidLoad()
        splitViewController!.delegate = self        

        //Lijst met items opvullen
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                //self.publiekSanitair = publiekSanitair.sort { $0.type_sanit < $1.type_sanit }
                self.publiekSanitair = publiekSanitair.sort { self.sortByDistance($0.location) < self.sortByDistance($1.location) }
                //self.publiekSanitair = publiekSanitair
                self.tableView.reloadData()
                self.errorView.hidden = true
            case .Failure(let error):
                self.errorLabel.text = "\(error)"
                self.errorView.hidden = false
            }
            //activityIndicator.stopAnimating()
        }
        currentTask!.resume()
        
        //Geodata
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
   
         print("locations in ViewDidLoad = \(locationManager.location?.coordinate.latitude) \(locationManager.location?.coordinate.longitude)")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 10;
        return publiekSanitair.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let lot = publiekSanitair[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = lot.type_sanit
        cell.detailTextLabel!.text = "\(sortByDistance(lot.location)) km"
        //cell.detailTextLabel!.text = "\(lot.availableCapacity)"
        return cell

        // Configure the cell...

    }
    
//  start copy code uit 'SplitView'
    
    deinit {
        print("Deinit")
        currentTask?.cancel()
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }

    
    @IBAction func refresh(sender: UIRefreshControl) {
        currentTask?.cancel()
        currentTask = Service.sharedService.createFetchTask {
            [unowned self] result in switch result {
            case .Success(let publiekSanitair):
                //self.publiekSanitair = publiekSanitair.sort { $0.description < $1.description }
                self.publiekSanitair = publiekSanitair.sort { self.sortByDistance($0.location) < self.sortByDistance($1.location) }
                //self.publiekSanitair = publiekSanitair
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detail = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        let selectedPubliekSanitair = publiekSanitair[tableView.indexPathForSelectedRow!.row]
        detail.publiekSanitair = selectedPubliekSanitair
    }
//  einde copy code uit 'SplitView'

    func sortByDistance(location: Location) -> Double{
//        //real actual location, but not working in simulator
//        let coordinates = locationManager.location?.coordinate
//        let location1 = CLLocation(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!)

        let location1 = CLLocation(latitude: 51.043291, longitude: 3.722861)
        let location2 = CLLocation(latitude: location.latitude, longitude: location.longitude)
        //Deel de afstand in meters door duizend en afrond op 1 decimaal na de komma
        return (Double(round(10*(location2.distanceFromLocation(location1))/1000)/10))
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
