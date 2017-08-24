//
//  Networking.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 23/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData

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
        for photo in photoAOD {
            if let url = photo["url_m"] {
                getImageDataFromURL(url : url as! String)
            }
        }
        
    }
    task.resume()
    
}

func getImageDataFromURL(url : String){
    
    let url = NSURLRequest(url: URL(string: url)!)
    let session = URLSession.shared
    let task = session.dataTask(with: url as URLRequest) { (data, response, error) in
        guard error == nil else{
            print("error while requesting data")
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("response other than 2xx")
            return
        }
        guard let data = data else {
            print("error getting data")
            return
        }
        print("got data from URL🍊")
        saveImageDataToCore(imageData: data)
        
    }
    task.resume()
    
}

func saveImageDataToCore(imageData : Data){
    let pin = CollectionViewController().pin
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedContext)!
    let photo = NSManagedObject(entity: entity, insertInto: managedContext)
    
    photo.setValue(imageData, forKey: "photoData")
    pin?.photo?.adding(photo)
    do{
        try managedContext.save()
        print("IMAGE DATA saved to core data")
    }catch {
        print("Could not save the IMAGE DATA to core data")
    }
}
