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

    var allPins = [Pin]()
//    var selectedPin : Pin? = nil (has been declared as global)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        doneButton.isEnabled = false
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(getCoordinates(gestureRecognizer:)))
        longGesture.minimumPressDuration = 1.0
        map.addGestureRecognizer(longGesture)
        
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        do{
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
            performSegue(withIdentifier: "toCollectionViewController", sender: self)
        }
        if editButton.isEnabled == false {
            mapView.removeAnnotation(view.annotation!)
            deletePinFromCore(latitude: (selectedPin?.latitude)!, longitude: (selectedPin?.longitude)!)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let collectionViewController = segue.destination as! CollectionViewController
//        collectionViewController.pin = selectedPin
//    }
//    
    func getCoordinates(gestureRecognizer : UILongPressGestureRecognizer){
    
        if editButton.isEnabled == true {
            if gestureRecognizer.state == .began {
                let location = gestureRecognizer.location(in: map)
                let coordinates = map.convert(location, toCoordinateFrom: map)
                
                saveCoordinatesToCore(latitude: coordinates.latitude, longitude: coordinates.longitude)
                createPin(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
        }
    }
    
    func saveCoordinatesToCore(latitude : CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
        
        pin.setValue(latitude, forKey: "latitude")
        pin.setValue(longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
        }catch {
            print("error saving latitude and longitude")
        }
    }
    
    func createPin(latitude : CLLocationDegrees, longitude: CLLocationDegrees){
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        map.addAnnotation(annotation)
    }
    
    func fetchPinsFromCore(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName : "Pin")
        
        do{
            allPins = try managedContext.fetch(fetchRequest)
        }catch {
            print("Error fetching all pins from Core")
        }
        for pin in allPins {
            createPin(latitude: pin.latitude, longitude: pin.longitude)
        }
    }
    
    func deletePinFromCore(latitude : CLLocationDegrees, longitude : CLLocationDegrees){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        
        do{
            let pins = try managedContext.fetch(fetchRequest)
            for pin in pins {
                if pin.latitude == latitude && pin.longitude == longitude {
                    managedContext.delete(pin)
                }
            }
        }catch{
            print("Error fetching pins from Core")
        }
        do{
            try managedContext.save()
        }catch{
            print("Error saving after deleting Pin")
        }
        
    }

}
