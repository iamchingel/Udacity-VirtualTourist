//
//  Networking.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 23/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import Foundation
import CoreLocation

func getImageURLSFromFlickr(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
  
    let request = NSMutableURLRequest(url: URL(string:"\(apiBaseURL)?method=\(apiMethod)&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&radius=\(radius)&extras=\(extras)&format=json&nojsoncallback=1")!)
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
        guard error == nil else{
            print("error while requesting data")
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("status code was other than 2xx")
            return
        }
        guard let data = data else {
            print("request for data failed")
            return
        }
        
        let parsedResult : [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        }catch {
            print("error parsing data")
            return
        }
        
        guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
            print("error getting the photos")
            return
        }
        guard let photoAOD = photos["photo"] as? [[String:AnyObject]] else{
            print("error error error ")
            return
        }
        
        print(photoAOD)
    }
    task.resume()
    
}
