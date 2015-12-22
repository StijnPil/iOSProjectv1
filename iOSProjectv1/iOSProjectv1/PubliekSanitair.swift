import Foundation
import MapKit

class PubliekSanitair
{
    let situering: String
    let type_sanit: String
    let type_locat: String
    let prijs_toeg: String
    let open7op7da: String
    let openuren: String
    let location: Location
    let address: String
    
    init(situering: String, type_sanit: String, type_locat: String, prijs_toeg: String, open7op7da: String, openuren: String, location: Location, address: String){
        self.situering = situering
        self.type_sanit = type_sanit
        self.type_locat = type_locat
        self.prijs_toeg = prijs_toeg
        self.open7op7da = open7op7da
        self.openuren = openuren
        self.location = location
        self.address = address
    }
}

//extension PubliekSanitair: CustomStringConvertible { }

extension PubliekSanitair
{
    convenience init(json: JSON) throws {
        
        guard let simpleData = json["ExtendedData"]["SchemaData"]["SimpleData"] as? JSON else{
            throw Service.Error.MissingJsonProperty(name: "SimpleData")
        }
        
        guard let simpleDataArray = simpleData.array else{
            throw Service.Error.MissingJsonProperty(name: "no simpleData array")
        }
        
        guard var situering = (simpleDataArray[1]["@text"].stringValue) as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for type_sanit")
        }
    
        if situering == ""{
            situering = "Publiek sanitair"
        }
        
        guard let type_sanit = simpleDataArray[2]["@text"].stringValue as? String  else{
            throw Service.Error.MissingJsonProperty(name: "@text for type_sanit")
        }

        guard let type_locat = simpleDataArray[3]["@text"].stringValue as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for type_locat")
        }
        
        guard let prijs_toeg = simpleDataArray[4]["@text"].stringValue as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for prijs_toeg")
        }
        
        guard let open7op7da = simpleDataArray[5]["@text"].stringValue as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for open7op7da")
        }
        
        guard let openuren = simpleDataArray[6]["@text"].stringValue as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for openuren")
        }
        
        guard let point = json["Point"]["coordinates"]["@text"].stringValue as? String else{
            throw Service.Error.MissingJsonProperty(name: "@text for coordinates in Point")
        }
        
        let pointArray = point.componentsSeparatedByString(",")
        let longitudeValue = (pointArray[0] as NSString).doubleValue
        let latitudeValue = (pointArray[1] as NSString).doubleValue
        
        //convert longitude and latitude to an address
        var locality : String = ""
        
        let longitude :CLLocationDegrees = longitudeValue
        let latitude :CLLocationDegrees = latitudeValue
        
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0{
                let pm = placemarks![0] as! CLPlacemark
                locality = "\(pm.thoroughfare), \(pm.subLocality)"
                pm.name
                print(pm.locality)
            }
            else {
                print("Problem with the data received from geocoder")
                locality = "Failed"
            }
        })
        
        self.init(situering: situering, type_sanit: type_sanit, type_locat: type_locat, prijs_toeg: prijs_toeg, open7op7da: open7op7da, openuren: openuren, location: Location(latitude: latitudeValue, longitude: longitudeValue), address: locality)
    }
}