//
//  CollectionViewController.swift
//  Udacity-VirtualTourist
//
//  Created by Sanket Ray on 21/08/17.
//  Copyright © 2017 Sanket Ray. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(pin?.latitude,pin?.longitude)
    }
    var pin : Pin?

}
