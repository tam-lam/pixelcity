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
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        locationManager.startUpdatingLocation()

    }
    
    @IBAction func centerMapwasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}
extension MapVC : MKMapViewDelegate{
    func centerMapOnUserLocation (){
        print("Centering")
        guard let coordinate = locationManager.location?.coordinate else {return}
        if coordinate != nil {
            print("Coordinate: \(coordinate)")
        }
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
extension MapVC : CLLocationManagerDelegate{
    
    //request permission to use location services
    func configureLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

