//
//  CollectionViewController.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 21/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewController: UIViewController {

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
        
        getImageURLSFromFlickr(latitude: (pin?.latitude)!, longitude: (pin?.longitude)!)
        
        print("🍒",pin?.photo?.count,"🍒",pin?.latitude,pin?.longitude)

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

}
