import Foundation
import MapKit

class Service
{
    enum Error: ErrorType
    {
        case InvalidJsonData(message: String?)
        case MissingJsonProperty(name: String)
        case MissingResponseData
        case NetworkError(message: String?)
        case UnexpectedStatusCode(code: Int)
    }
    
    static let sharedService = Service()
    
    private let url: NSURL
    private let session: NSURLSession
    
    private init() {
        let path = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist")!
        let properties = NSDictionary(contentsOfFile: path)!
        url = NSURL(string: properties["baseUrlSanitair"] as! String)!
        session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }

    
    func createFetchTask(completionHandler: Result<[PubliekSanitair]> -> Void) -> NSURLSessionTask {
        return session.dataTaskWithURL(url) {
            data, response, error in
            let completionHandler: Result<[PubliekSanitair]> -> Void = {
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
                let json = JSON(data: data)
                let placemarks = json["Document"]["Folder"]["Placemark"].array!
        
                let sanitairs = try placemarks.map{ try PubliekSanitair(json: $0) }

                completionHandler(.Success(sanitairs))

            } catch let error as Error {
                completionHandler(.Failure(error))
            } catch let error as NSError {
                completionHandler(.Failure(.InvalidJsonData(message: error.description)))
            }
        }
    }
    

}