//
//  ViewController.swift
//  pixelcity
//
//  Created by Graphene on 5/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        mapView.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func centerMapwasPressed(_ sender: Any) {
    }
    
}
extension MapVC : MKMapViewDelegate{
    
}

