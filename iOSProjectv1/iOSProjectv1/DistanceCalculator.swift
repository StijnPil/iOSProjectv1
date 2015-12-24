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
    
    let APIKey = "AIzaSyBvcpFTa2-dbH2ya9WpbW4X0fn2utgtXhc"
    static func calculateDistance(userLocation: CLLocation, sanitairs: [PubliekSanitair], travelMode : String) -> [Double]{
        let originsUrl = "origins=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
        var destinationCoordinates : String = ""
        var distances: [Double] = []
        var testCounter = 0
        
        //Coordinaten van elk publiek sanitoer toevoegen aan destinations
        var location: Location
        for sanitair in sanitairs{
            location = sanitair.location;
            
            if destinationCoordinates.characters.count > 800{
                distances.appendContentsOf(performDistanceRequest(originsUrl, locationCoordinates: destinationCoordinates, travelMode: travelMode, testCounter: testCounter))
                destinationCoordinates = ""
                testCounter = 0
            } else{
                if( location.latitude == 0){
                    print("\(sanitair.situering) geen latitude")
                }
                if( location.longitude == 0){
                    print("\(sanitair.situering) geen latitude")
                }
                destinationCoordinates.appendContentsOf("|\(location.latitude),\(location.longitude)")
                testCounter++
            }
        }
        
        distances.appendContentsOf(performDistanceRequest(originsUrl, locationCoordinates: destinationCoordinates, travelMode: travelMode, testCounter: testCounter))
        
        return distances
        
        //let destinations = "destinations=\(sanitairLocation.coordinate.latitude),\(sanitairLocation.coordinate.longitude)"
        
        
        //let requestURL = "https://maps.googleapis.com/maps/api/distancematrix/json?\(origins)&\(destinations)&mode=\(travelMode)"
        
        
//        do{
//            guard let value = try json["rows"].array![0]["elements"].array![0]["distance"]["value"] as? JSON else{
//                throw Service.Error.MissingJsonProperty(name: "value")
//            } catch Service.Error.Mi
//        }

        
        //let value = try json["rows"].array![0]["elements"].array![0]["distance"]["value"] as? JSON
     
    }
    
    private static func performDistanceRequest(originsUrl: String, locationCoordinates: String, travelMode: String, testCounter: Int) -> [Double]{
        let originsUrl = originsUrl
        let destinationsUrl = ("destinations=\(locationCoordinates)")
        var test = ""
        test.appendContentsOf("opnieuw")
        
        //request URL samenstellen
        var requestURL = "https://maps.googleapis.com/maps/api/distancematrix/json?"
        requestURL.appendContentsOf(originsUrl)
        requestURL.appendContentsOf("&")
        requestURL.appendContentsOf(destinationsUrl)
        requestURL.appendContentsOf("&")
        requestURL.appendContentsOf("mode=\(travelMode)")
        requestURL.appendContentsOf("&")
        requestURL.appendContentsOf("key=AIzaSyBvcpFTa2-dbH2ya9WpbW4X0fn2utgtXhc")
        
        let endpoint = NSURL(string: requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        
        let data = NSData(contentsOfURL: endpoint)
        var json = JSON(data: data!)
        
        let values = try json["rows"].array![0]["elements"].array!
        var distances : [Double]! = []
        var counter = 0;
        for value in values{
            let doubleValue = value["distance"]["value"]
            if doubleValue.int64 == nil {
                print ("TestCounter: \(testCounter), counter: \(counter) \(doubleValue.int64)")
            }
            distances.append((Double(round(10*(Double(doubleValue.int64!))/1000)/10)))
            counter++;
        }
        return distances
    }
}