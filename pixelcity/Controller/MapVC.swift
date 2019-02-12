//
//  ViewController.swift
//  pixelcity
//
//  Created by Graphene on 5/2/19.
//  Copyright © 2019 tam-lam. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireImage

class MapVC: UIViewController , UIGestureRecognizerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var spinner : UIActivityIndicatorView?
    var progressLbl: UILabel?
    var collectionView : UICollectionView?
    
    var flowLayout = UICollectionViewFlowLayout()
    var screenSize = UIScreen.main.bounds
    var imageURLArray = [String]()
    var imageArray = [UIImage]()
    
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
        cancelAllSession()
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
        spinner?.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
        progressLbl?.font = UIFont(name: "Avenir Next", size: 15)
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
    func retriveUrls(forAnnotation annotation:DroppablePin, handler: @escaping (_ status: Bool)->()){
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 10)).responseJSON { (response) in
            guard let json =  response.result.value as? Dictionary<String, AnyObject> else{return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photoDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photoDictArray{
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_z_d.jpg"
                self.imageURLArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool)->()){        
        for url in imageURLArray{
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 PHOTOS DOWNLOADED"
                
                if self.imageURLArray.count == self.imageArray.count{
                    handler(true)
                }
            }
        }
    }
    
    func cancelAllSession(){
        var sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { (sessionTasks, uploadTasks, downloadTasks) in
            sessionTasks.forEach({ $0.cancel()})
            downloadTasks.forEach({$0.cancel()})
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
        cancelAllSession()
        
        imageArray = []
        imageURLArray = []
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        progressLbl?.text = "0/40 PHOTOS LOADED"
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        retriveUrls(forAnnotation: annotation) { (finished) in
            if finished{
                self.retrieveImages(handler: { (finished) in
                    if finished{
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
        
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
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:  PhotoCell  = ((collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell)) else {return UICollectionViewCell()}
        let imageFromIndex = self.imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        return cell
    }
    
    
}
