//
//  CollectionViewController.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 21/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var pin : Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(10,0,10,0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 5
        myCollectionView.collectionViewLayout = layout
        
        addAnnotationToMap(latitude: (pin?.latitude)!,longitude: (pin?.longitude)!)
       
        if (pin?.photo?.count)! == 0 {
            getImageURLSFromFlickr(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!)
            do{
                try fetchedResultsController.performFetch()
            }catch{
                print("An error occured")
            }
        }
    
        if (pin?.photo?.count)! > 0 {
            do {
                try fetchedResultsController.performFetch()
            }catch{
                print("An error occured")
            }
        }

    }
//    IBOutlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    func addAnnotationToMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        map.addAnnotation(annotation)
        
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let span = MKCoordinateSpanMake(5, 5)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        
    }

    lazy var fetchedResultsController : NSFetchedResultsController = { () -> NSFetchedResultsController<Photo> in
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        let sortDescriptor = NSSortDescriptor(key: "photoURL", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let frc  = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath{
                self.myCollectionView.insertItems(at: [insertIndexPath])
            }
        case .delete:
            if let deleteIndexpath = indexPath{
                self.myCollectionView.deleteItems(at: [deleteIndexpath])
            }
//        case .update:
//            if let updateIndexPath = indexPath {
//                let cell = self.myCollectionView.cellForItem(at: updateIndexPath) as! CollectionViewCell
//                let photo = self.fetchedResultsController.object(at: updateIndexPath)
//                cell.image.image = UIImage(data: photo.photoData! as Data)
//            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.myCollectionView.deleteItems(at: [deleteIndexPath])
            }
            if let insertIndexPath = newIndexPath {
                self.myCollectionView.insertItems(at: [insertIndexPath])
            }
        default:
            ""
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.myCollectionView.insertSections(sectionIndexSet as IndexSet)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.myCollectionView.deleteSections(sectionIndexSet as IndexSet)
        default:
            print("Nothing")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
}

extension CollectionViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        
        cell.image.image = UIImage(data: photo.photoData! as Data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(photo)
    }
}
