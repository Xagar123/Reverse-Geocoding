//
//  ViewController.swift
//  MapKit project
//
//  Created by Admin on 25/12/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    
    private let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChange), for: .valueChanged)
    }

    @objc func mapTypeChange(segmentedControl: UISegmentedControl) {
        switch(segmentedControl.selectedSegmentIndex) {
            
        case 0:
            self.mapView.mapType = .standard
        case 1:
            self.mapView.mapType = .satellite
        case 2:
            self.mapView.mapType = .hybrid
        default:
            self.mapView.mapType = .standard
        }
        
    }
    
    @IBAction func addAnnotationButton(_ sender: UIButton) {
        let annotation = ShopAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 25.578773, longitude: 91.893257)
        annotation.title = "cofee shop"
        annotation.subtitle = "get your delicioous coffee"
        annotation.imageURL = "logo"
        self.mapView.addAnnotation(annotation)
        print("annotaion button tapped")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        var shopAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "shopAnnotation") as? MKMarkerAnnotationView
    
        if shopAnnotation == nil {
            shopAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "shopAnnotation")
            shopAnnotation?.glyphText = "☕️"
            shopAnnotation?.markerTintColor = UIColor.blue
            shopAnnotation?.glyphTintColor = UIColor.white
            shopAnnotation?.canShowCallout = true
        }else {
            shopAnnotation?.annotation = annotation
        }
//        if let shopAnnotation = annotation as? ShopAnnotation {
//       //     shopAnnotation.image = UIImage(named: shopAnnotation.imageURL)
//        }
        configureView(shopAnnotation)
        return shopAnnotation
    }
    
//    private func configureView(_ annotationView: MKAnnotationView?) {
//        //details accessary view
//        let view = UIView(frame: CGRect.zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        view.backgroundColor = UIColor.red
//
//        annotationView?.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "cup"))
//        annotationView?.rightCalloutAccessoryView = UIImageView(image: UIImage(named: "cup"))
//        annotationView?.detailCalloutAccessoryView = view
//    }
    
    //custome Annotation
    private func configureView(_ annotationView: MKAnnotationView?) {
       let snapShotSize = CGSize(width: 200, height: 200)
        let snapShotView = UIView(frame: CGRect.zero)
        snapShotView.translatesAutoresizingMaskIntoConstraints = false
        snapShotView.widthAnchor.constraint(equalToConstant: snapShotSize.width).isActive = true
        snapShotView.heightAnchor.constraint(equalToConstant: snapShotSize.height).isActive = true
        
        let option = MKMapSnapshotter.Options()
        option.size = snapShotSize
        option.mapType = .satelliteFlyover
        option.camera = MKMapCamera(lookingAtCenter: (annotationView?.annotation!.coordinate)!, fromDistance: 10, pitch: 65, heading: 0 )
        
        let snapshotter = MKMapSnapshotter(options: option)
        snapshotter.start { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: snapShotSize.width, height: snapShotSize.height))
                imageView.image = snapshot.image
                snapShotView.addSubview(imageView)
            }
        }
        annotationView?.detailCalloutAccessoryView = snapShotView
    }
     
    
    //reverse geocoding
    @IBAction func showAddAddressView(_ sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: "Add Address", message: nil, preferredStyle: .alert)
        alertVC.addTextField{ textField in
            
        }
        let okAction = UIAlertAction(title: "OK", style: .default)
        {
            action in
            
            if let textField = alertVC.textFields?.first {
                // reverse geocode the address
                self.reverseGeocode(address: textField.text!)
            }
        }
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel) { action in
            
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancleAction)
        
        self.present(alertVC, animated: true)
    }
    
    func reverseGeocode(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placemarks = placemarks,
                  let placemark = placemarks.first else {
                return
            }
            self.addPlacemarkToMap(placemark: placemark)
            
        }
    }
    
    func addPlacemarkToMap(placemark: CLPlacemark) {
        
        let coordinate = placemark.location?.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        self.mapView.addAnnotation(annotation)
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        mapView.setRegion(region, animated: true)
    }

}

