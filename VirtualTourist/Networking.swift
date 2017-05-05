//
//  Networking.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/17/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation
import UIKit

class Networking: NSObject {
    
    var session = URLSession.shared
    var appDelegate: AppDelegate!
    
    //Is this necessary below
    override init() {
        super.init()
    }
    
    let methodParameter: [String:AnyObject] = [
        Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey as AnyObject,
        Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod as AnyObject,
        Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
        Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat as AnyObject,
        Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback as AnyObject,
        Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL as AnyObject,
        Constants.FlickrParameterKeys.PerPage : "21" as AnyObject
    ]
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    func imagesFromFlickr(bbox: String, completionHandlerForData: @escaping(_ success: Bool, _ photoArray: [[String:AnyObject]]?, _ error: String?) -> Void) {
        
        var withBBoxDictionary = methodParameter
        withBBoxDictionary["bbox"] = bbox as AnyObject
        let urlString = Constants.Flickr.BaseURL + escapedParameters(withBBoxDictionary)
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            guard (error == nil) else {
                completionHandlerForData(false, [], error as? String)
                print("error in error - 1")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
               completionHandlerForData(false, [], error as? String)
                print("error in statuscode - 1")
                return
            }
            
            guard let data = data else {
                completionHandlerForData(false, [], error as? String)
                print("error in data - 1")
                return
            }
        
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                print(userInfo)
                completionHandlerForData(false, [], error as? String)
                return
            }
           
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completionHandlerForData(false, [], error as? String)
                print("error in stat - 1")
                return
            }
            
            guard let photoDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForData(false, [], error as? String)
                print("error in photodictionary - 1")
                return
            }
            
            guard let totalPages = photoDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                completionHandlerForData(false, [], error as? String)
                print("error in totalpages - 1")
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            Networking.sharedInstance().imagesFromFlickr(methodParameter: withBBoxDictionary, withPageNumber: randomPage, completionHandleWithPage: completionHandlerForData)
        }
        task.resume()
    }
    
    // create the func for page number info
    
    func imagesFromFlickr(methodParameter: [String:AnyObject], withPageNumber: Int, completionHandleWithPage: @escaping(_ success: Bool,_ photoArray: [[String:AnyObject]], _ error: String?) -> Void) {
        
        var methodArgumentsWithPageNumber = methodParameter
        methodArgumentsWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject
        
        let urlString = Constants.Flickr.BaseURL + escapedParameters(methodArgumentsWithPageNumber)
        print(urlString)
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandleWithPage(false, [], error as? String)
                print("error in error - 2")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandleWithPage(false, [], error as? String)
                print("error in statuscode - 2")
                return
            }
            
            guard let data = data else {
                completionHandleWithPage(false, [], error as? String)
                print("error in data - 2")
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                print(userInfo)
                completionHandleWithPage(false, [], error as? String)
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completionHandleWithPage(false, [], error as? String)
                print("error in stat - 2")
                return
            }
            
            guard let photoDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandleWithPage(false, [], error as? String)
                print("error in photodictionary - 2")
                return
            }
            
            guard let totalPhotos = (photoDictionary[Constants.FlickrResponseKeys.Pages] as? Int) else {
                completionHandleWithPage(false, [], error as? String)
                print("error in totalpages - 2 \(String(describing: error as NSError?))")
                return
            }
            
            print(totalPhotos)
            
            if totalPhotos > 0 {
    
                guard let photosArray = photoDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                   completionHandleWithPage(false, [], error as? String)
                    print("error in photoarray - 2")
                    return
                }
                completionHandleWithPage(true, photosArray, nil)
                
            } else {
                
                DispatchQueue.main.async {
                    print("No photos available")
                    completionHandleWithPage(false, [], error as? String)
                }
            }
        }
        task.resume()
    }
    
    //This function takes the image URL and passes back image
    func imageData(_ stringURL: String, completionHandlerForImage: @escaping(_ imageData: NSData?, _ error: String?) -> Void) -> URLSessionTask {
        
        let baseURL = NSURL(string: stringURL)!
        
        let request = NSURLRequest(url: baseURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                print("error in request")
                
            } else {
                completionHandlerForImage(data as NSData?, nil)
            }
        }
        task.resume()
        
        return task
    }
    
    class func sharedInstance() -> Networking {
        struct Singleton {
            static var sharedInstance = Networking()
        }
        return Singleton.sharedInstance
    }
}
