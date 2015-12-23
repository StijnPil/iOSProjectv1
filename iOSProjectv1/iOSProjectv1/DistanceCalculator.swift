//
//  DistanceCalculator.swift
//  iOSProjectv1
//
//  Created by Stijn Pillaert on 23/12/15.
//  Copyright © 2015 Stijn Pillaert. All rights reserved.
//

import Foundation
import MapKit

class DistanceCalculator{
    
    static func calculateDistance(userLocation: CLLocation, sanitairLocation: CLLocation, travelMode : String) -> Double{
        let origins = "origins=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
        let destinations = "destinations=\(sanitairLocation.coordinate.latitude),\(sanitairLocation.coordinate.longitude)"
        let requestURL = "https://maps.googleapis.com/maps/api/distancematrix/json?\(origins)&\(destinations)&mode=\(travelMode)"
        let endpoint = NSURL(string: requestURL)!
        let data = NSData(contentsOfURL: endpoint)
        var json = JSON(data: data!)
        
//        do{
//            guard let value = try json["rows"].array![0]["elements"].array![0]["distance"]["value"] as? JSON else{
//                throw Service.Error.MissingJsonProperty(name: "value")
//            } catch Service.Error.Mi
//        }
        let value = try json["rows"].array![0]["elements"].array![0]["distance"]["value"] as? JSON
        
   
    
        let distance = (Double(round(10*(Double(value!.int64!))/1000)/10))
        print(distance)
        return distance
    }
}