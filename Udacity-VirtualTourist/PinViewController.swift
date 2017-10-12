//
//  PinViewController.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 21/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {

//  We will be using this allPins variable later on to store, data fetched from database.
    var allPins = [Pin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//      initially the done button is disabled. This can also be done in utilities inspector!
        doneButton.isEnabled = false
        
//      Here we create a gesture recogniser. If you press the screen for a min duration of 1.0 sec, we execute the function "getCoordinates".
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(getCoordinates(gestureRecognizer:)))
        longGesture.minimumPressDuration = 1.0
        
//      adding gestureRecognizer to the map. Getures wont work on the map unless we add this.
        map.addGestureRecognizer(longGesture)

//      Everytime the view loads, we need to fetch the pins, as they are already stored in the database and this app supports persistence.
        fetchPinsFromCore()
        
    }
    
    //IBOutlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    //IBActions
    @IBAction func editAction(_ sender: Any) {
        editButton.isEnabled = false
        doneButton.isEnabled = true
    }
    @IBAction func doneAction(_ sender: Any) {
        editButton.isEnabled = true
        doneButton.isEnabled = false
    }

//  didSelect is a method of MKMapViewDelegate. This is executed when we tap on a pin.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        do{
//          Here we fetch an array of PIN. [PIN] and then we loop over each PIN to find out the right pin. We try to find the pin we tapped on from the                                                                                                                                                                                                 array of PIN. Next we save the found out pin as "selectedPin".
            let pins = try managedContext.fetch(fetchRequest)
            for pin in pins {
                if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                    selectedPin = pin
                }
            }
        }catch{
            print("Error fetching Pins from core")
        }
        
        if editButton.isEnabled == true {
//          when this block is excecuted, it means we are trying to find out all the images associated with the pin. We segue to the next view controller.
            performSegue(withIdentifier: "toCollectionViewController", sender: self)
        }
        if editButton.isEnabled == false {
            
//          when this block is executed, it means we are trying to delete the pin we tapped on. First we remove the annotation from the map and then the reference of the pin from database using CoreData.
            mapView.removeAnnotation(view.annotation!)
            deletePinFromCore(latitude: (selectedPin?.latitude)!, longitude: (selectedPin?.longitude)!)
        }
    }
    
    
//  the function getCoordinates converts the touched point into a CGPoint and then into a Coordinate, which is later saved using CD and an annotation is displayed the point of touch.
    func getCoordinates(gestureRecognizer : UILongPressGestureRecognizer){
    
        if editButton.isEnabled == true {
            if gestureRecognizer.state == .began {
                
//              we get a CGPoint after calling "gestureRecognizer.location(in: map)" which is stored as the location.
                let location = gestureRecognizer.location(in: map)
//              we convert the above CGPoint into a CLLOcationCoordinate2D by using map.convert
                let coordinates = map.convert(location, toCoordinateFrom: map)
                
//              we save the coordinates obtained above to the database using CoreData. latitude and longitude are both saved as Doubles
                saveCoordinatesToCore(latitude: coordinates.latitude, longitude: coordinates.longitude)
//              After saving the coordinates to database, we use the same latitude and longitude to draw an annotation on the map!
                createPin(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
        }
    }
    
    func saveCoordinatesToCore(latitude : CLLocationDegrees, longitude: CLLocationDegrees) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//      Here we are getting hold of the context, which is used to delete something, or fetch something from the database.
        let managedContext = appDelegate.persistentContainer.viewContext
//      We need to save the latitude and longitude passed in as parameters to the entity "PIN's" attributes.
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
        
//      Here we save the value of latitude and longitude for the respective keys
        pin.setValue(latitude, forKey: "latitude")
        pin.setValue(longitude, forKey: "longitude")
        
/*
        We could also use this method. The method written below is advised!
        
        let pin = NSManagedObject(entity: entity, insertInto: managedContext) as! Pin
        pin.latitude = latitude
        pin.longitude = longitude
*/
        
        
//      The managedContext is written inside a 'DO' block since, the save method throws.
        do {
            try managedContext.save()
        }catch {
            print("error saving latitude and longitude")
        }
    }
    
//  The function createPin simply creates an annotation on the map, using the passed in latitude and longitude
    func createPin(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        map.addAnnotation(annotation)
    }
//  We are fetching the pins from database using CoreData, when the view loads for the first time.
    func fetchPinsFromCore(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        
        do{
            allPins = try managedContext.fetch(fetchRequest)
        }catch {
            print("Error fetching all pins from Core")
        }
        
//      After getting the array of PIN, we need to create the annotaions on the map, so that, it looks like the app can persist data properly.
        for pin in allPins {
            createPin(latitude: pin.latitude, longitude: pin.longitude)
        }
    }
    
//  This function deletes a pin from the database.
    func deletePinFromCore(latitude : CLLocationDegrees, longitude : CLLocationDegrees){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        do{
            let pins = try managedContext.fetch(fetchRequest)
            for pin in pins {
                if pin.latitude == latitude && pin.longitude == longitude {
//                  we delete the pin in the line below. First we loop through all the pins fetched and try to find the right pin by matching with the latitude and longitude passed in as parameters to the function.
                    managedContext.delete(pin)
                }
            }
        }catch{
            print("Error fetching pins from Core")
        }
        
//      We need to save the managedContext after deleting the pin. Hmmm, can't we just save in the above do-try block????
        do{
            try managedContext.save()
        }catch{
            print("Error saving after deleting Pin")
        }
    }
}

