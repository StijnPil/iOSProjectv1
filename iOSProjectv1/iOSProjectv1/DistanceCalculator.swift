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
        
        //Coordinaten van elk publiek sanitair toevoegen aan destinations
        var location: Location
        for sanitair in sanitairs{
            location = sanitair.location;
            
            //Een request url naar de Google Distance Matrix API mag niet groter zijn dan 2000 tekens.
            //Uit voorzorg wordt bij meer dan 1700 tekens de request al opgesplitst
            if destinationCoordinates.characters.count > 1700{
                destinationCoordinates.appendContentsOf("|\(location.latitude),\(location.longitude)")
                distances.appendContentsOf(performDistanceRequest(originsUrl, locationCoordinates: destinationCoordinates, travelMode: travelMode))
                destinationCoordinates = ""
            } else{
                destinationCoordinates.appendContentsOf("|\(location.latitude),\(location.longitude)")
            }
        }
        
        distances.appendContentsOf(performDistanceRequest(originsUrl, locationCoordinates: destinationCoordinates, travelMode: travelMode))
        return distances
    }
    
    private static func performDistanceRequest(originsUrl: String, locationCoordinates: String, travelMode: String) -> [Double]{
        let originsUrl = originsUrl
        let destinationsUrl = ("destinations=\(locationCoordinates)")
        
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
        for value in values{
            let doubleValue = value["distance"]["value"]
            distances.append((Double(round(10*(Double(doubleValue.int64!))/1000)/10)))
        }
        return distances
    }
}