//
//  GoogleMapsAPI.swift
//  iOSProjectv1
//
//  Created by Stijn Pillaert on 15/01/16.
//  Copyright © 2016 Stijn Pillaert. All rights reserved.
//

import Foundation
import MapKit

class GoogleMapsAPI{
    static let sharedService = GoogleMapsAPI()
    
    private var url =  NSURL(string: "")
    private var session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    
     func setUrl(baseUrl: String){
        url = NSURL(string: baseUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
    }
    
    
     func createFetchTask(completionHandler: Result<[Double]> -> Void) -> NSURLSessionTask {
        return session.dataTaskWithURL(url!) {
            data, response, error in
            let completionHandler: Result<[Double]> -> Void = {
                result in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    completionHandler(result)
                }
            }
            guard let response = response as? NSHTTPURLResponse else {
                completionHandler(.Failure(.NetworkError(message: error?.description)))
                return
            }
            guard response.statusCode == 200 else {
                completionHandler(.Failure(.UnexpectedStatusCode(code: response.statusCode)))
                return
            }
            guard let data = data else {
                completionHandler(.Failure(.MissingResponseData))
                return
            }
            
            
            do {
                var json = JSON(data: data)
                let values = try json["rows"].array![0]["elements"].array!
                var distances : [Double]! = []
                for value in values{
                    let doubleValue = value["distance"]["value"]
                    distances.append((Double(round(10*(Double(doubleValue.int64!))/1000)/10)))
                }
                completionHandler(.Success(distances))
                
            } catch let error as Error {
                completionHandler(.Failure(error))
            } catch let error as NSError {
                completionHandler(.Failure(.InvalidJsonData(message: error.description)))
            }
        }
    }
}

