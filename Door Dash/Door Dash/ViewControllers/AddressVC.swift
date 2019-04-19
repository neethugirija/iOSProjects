//
//  ViewController.swift
//  Door Dash
//
//  Created by Neethu Girija on 4/16/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddressVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressBox: UITextField!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 100
    var pin:MKPointAnnotation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeView()
        checkLocationServices()
    }
    
    
    //customizing view elements
    func customizeView() {
        let label = UILabel.init()
        label.text = "Choose an Address"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.regular)
        label.sizeToFit()
        navigationItem.titleView = label

        let mapButton = UIButton(type: .system)
        navigationItem.backBarButtonItem = UIBarButtonItem(customView: mapButton)
    }

    //checking if location services are enabled or not
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            showAlert(title: "Location", message: "Please turn on the location services in settings")
        }
    }

    //Setting location manager delegate to self & desired accuracy
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //checking if location authorization is available. If yes, center current location on map.
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            showAlert(title: "Location", message: "Please enable access in settings")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(title: "Location", message: "Disable restrictions to continue using the app")
        case .authorizedAlways:
            startTackingUserLocation()
        }
    }
    
    //track user location
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    //get center location of MapView
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //presenting alert
    func showAlert(title: String, message:String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //centering location in view
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)

        }
    }
    
    //verifying & confirming address
    @IBAction func confirmAddress(_ sender: Any) {
        if addressBox.text?.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            showAlert(title: "Address Missing", message: "Please select a valid Address")
            return
        }
        performSegue(withIdentifier: "toExplore", sender: self)
    }
    
    // Passing the selected location
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExplore" {
            if let tabBarController = segue.destination as? UITabBarController {
                if let destinationViewController = tabBarController.viewControllers?[0] as? ExploreVC {
                    destinationViewController.location = getCenterLocation(for: mapView)
                }
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension AddressVC: CLLocationManagerDelegate {
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    //check authorization when status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

//MARK: - MKMapViewDelegate

extension AddressVC: MKMapViewDelegate {
    //updating address box by converting location to placemark
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Geocode Error", message: error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.showAlert(title: "Placemark Error", message: "Unable to get placemark")
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            if  self.pin == nil {
                self.pin = MKPointAnnotation()
                self.pin!.coordinate = center.coordinate
                mapView.addAnnotation(self.pin!)
            } else {
                self.pin?.coordinate = center.coordinate
            }
            
            DispatchQueue.main.async {
                self.addressBox.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
}
