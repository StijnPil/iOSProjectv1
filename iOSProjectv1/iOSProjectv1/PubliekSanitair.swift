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
    var distanceToUser: Double
    
    init(situering: String, type_sanit: String, type_locat: String, prijs_toeg: String, open7op7da: String, openuren: String, location: Location, distanceToUser: Double){
        self.situering = situering
        self.type_sanit = type_sanit
        self.type_locat = type_locat
        self.prijs_toeg = prijs_toeg
        self.open7op7da = open7op7da
        self.openuren = openuren
        self.location = location
        self.distanceToUser = distanceToUser
    }
    
    func setDistanceToUser(latitude: Double, longitude: Double, travelMode: String)  {
        //let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        let userLocation = CLLocation(latitude: 51.043291, longitude: 3.722861)
        let sanitairLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = DistanceCalculator.calculateDistance(userLocation, sanitairLocation: sanitairLocation, travelMode: travelMode)
        distanceToUser = distance
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
        
        
        let userLocation = CLLocation(latitude: 51.043291, longitude: 3.722861)
        let sanitairLocation = CLLocation(latitude: latitudeValue, longitude: longitudeValue)
        //let distanceToUser = try DistanceCalculator.calculateDistance(userLocation, sanitairLocation: sanitairLocation, travelMode: "walking")
        let distanceToUser = 0 as Double;
        
        self.init(situering: situering, type_sanit: type_sanit, type_locat: type_locat, prijs_toeg: prijs_toeg, open7op7da: open7op7da, openuren: openuren, location: Location(latitude: latitudeValue, longitude: longitudeValue), distanceToUser: distanceToUser)
    }
}