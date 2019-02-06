//
//  ViewController.swift
//  pixelcity
//
//  Created by Graphene on 5/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController , UIGestureRecognizerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var spinner : UIActivityIndicatorView?
    var progressLbl: UILabel?
    var collectionView : UICollectionView?
    
    var flowLayout = UICollectionViewFlowLayout()
    var screenSize = UIScreen.main.bounds
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoubleTap()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        locationManager.startUpdatingLocation()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MapVC.dropPin))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate  = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapVC.animateViewDown))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MapVC.animateViewDown))
        swipeDown.direction = .down
        swipeDown.delegate = self
        pullUpView.addGestureRecognizer(swipeDown)
        pullUpView.addGestureRecognizer(tapGesture)
    }
    func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func animateViewDown(){
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            self.pullUpView.updateConstraints()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        let xPoint =  (screenSize.width / 2) - (spinner?.frame.width)!/2
        spinner?.center = CGPoint(x: xPoint, y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView!.addSubview(spinner!)
    }
    func removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView!.addSubview(progressLbl!)
    }
    func removeProgressLbl(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }
    @IBAction func centerMapwasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}
extension MapVC : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    func centerMapOnUserLocation (){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        removeSpinner()
        removeProgressLbl()
        removePin()
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        progressLbl?.text = "12 PHOTOS LOADED"
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    func addNotationToMapView(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
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

extension MapVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:  PhotoCell  = ((collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell)!)
        return cell
    }
    
    
}
