//
//  StationDetailsViewController.swift
//  CitiBike NYC
//
//  Created by Neethu G on 2/17/19.
//  Copyright © 2019 Neethu G. All rights reserved.
//

import UIKit
import MapKit

class StationDetailsViewController: UIViewController {
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var availableDocksLabel: UILabel!
    @IBOutlet weak var totalDocksLabel: UILabel!
    @IBOutlet weak var availableBikesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var station:Station?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewData()
    }

    //MARK: - Updating UI
    
    func loadViewData(){
        if self.station != nil{
            self.stationNameLabel.text = self.station!.stationName
            self.availableDocksLabel.text = "Available Docks: \(String(describing: self.station!.availableDocks))"
            self.totalDocksLabel.text = "Total Docks: \(String(describing: self.station!.totalDocks))"
            self.availableBikesLabel.text = "Available Bikes: \(String(describing: self.station!.availableBikes))"
            self.loadMapView()
        } else {
            print("Unable to retrieve Station")
        }
    }

    //MARK: - Loading Map

    func loadMapView() {

        // Locating point on map & adjusting span
        let latitude: CLLocationDegrees = Double(self.station!.latitude)
        let longitude: CLLocationDegrees = Double(self.station!.longitude)
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)

        // Drop a pin at the given location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        myAnnotation.title = self.stationNameLabel.text
        mapView.addAnnotation(myAnnotation)
    }
}
