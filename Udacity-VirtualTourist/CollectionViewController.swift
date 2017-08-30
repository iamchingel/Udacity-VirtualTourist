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
import CoreLocation

class CollectionViewController: UIViewController, NSFetchedResultsControllerDelegate {

//  var pin : Pin?
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(10,0,10,0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 5
        myCollectionView.collectionViewLayout = layout
        
        addAnnotationToMap(latitude: (selectedPin?.latitude)!,longitude: (selectedPin?.longitude)!)
  
        getDetailsFromFlickr(latitude: (selectedPin?.latitude)!, longitude: (selectedPin?.longitude)!) { (pages, numberOfImages) in
            if pages != nil {
                print(pages!,"🍝🍽🍝")
                let randomPage = arc4random_uniform(UInt32(pages!)) + 1
                if (selectedPin?.photo?.count)! == 0 {
                    getImageURLSFromFlickr(latitude: (selectedPin?.latitude)!, longitude: (selectedPin?.longitude)!, page: Int(randomPage))
                }
            }
            if numberOfImages != nil {
                print(numberOfImages!,"🍝🍽🍝")
            }
        }
        
        do {
            try self.fetchedResultsController.performFetch()
        }catch{
            print("An error occured")
        }

    }
    @IBAction func newImageCollection(_ sender: Any) {
//        Need to delete all images and update data base ...but how???
        

        
        
        
        let randomPageNumber = arc4random_uniform(UInt32(totalPages)) + 1
        print(randomPageNumber,"🥕🥕🥕🥕🥕🥕🥕")
        getImageURLSFromFlickr(latitude: (selectedPin?.latitude)!, longitude: (selectedPin?.longitude)!, page: Int(randomPageNumber))
    }
    
    
//  IBOutlets
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
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [selectedPin!])
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
//      case .update:
//          if let updateIndexPath = indexPath {
//             let cell = self.myCollectionView.cellForItem(at: updateIndexPath) as! CollectionViewCell
//             let photo = self.fetchedResultsController.object(at: updateIndexPath)
//             cell.image.image = UIImage(data: photo.photoData! as Data)
//          }
        case .move:
            if let deleteIndexPath = indexPath {
                self.myCollectionView.deleteItems(at: [deleteIndexPath])
            }
            if let insertIndexPath = newIndexPath {
                self.myCollectionView.insertItems(at: [insertIndexPath])
            }
        default:
            print("")
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.myCollectionView.numberOfItems(inSection: 0)
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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let photo = fetchedResultsController.object(at: indexPath)
        managedContext.delete(photo)
        
        do{
            try managedContext.save()
        }catch {
            print("Error while saving")
        }
    }
}

func getDetailsFromFlickr(latitude : CLLocationDegrees, longitude : CLLocationDegrees, completion : @escaping (_ pages: Int?, _ numberOfImages: Int?)->Void){
    
    let url = NSMutableURLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ad83a09291b05b32fedea7e5993714d7&lat=\(latitude)&lon=\(longitude)&extras=url_m&per_page=20&format=json&nojsoncallback=1")!)
    
    let session = URLSession.shared
    let task = session.dataTask(with: url as URLRequest) { (data, response, error) in
        
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
        totalPages = (photos["pages"])! as! Int
        completion(totalPages, nil)
        
        guard let photo = photos["photo"] as? [[String:AnyObject]] else {
            print("error getting the list of photos")
            return
        }
        numberOfImagesInPage = (photo.count)
        completion(nil,numberOfImagesInPage)
    }
    task.resume()
}









