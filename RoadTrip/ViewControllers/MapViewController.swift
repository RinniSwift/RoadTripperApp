//
//  MapViewController.swift
//  RoadTrip
//
//  Created by Rinni Swift on 12/14/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MapViewController: UIViewController {
    
    // MARK: - Variables
    var friendLocation = CLLocationCoordinate2D()
    var friendEmail = ""
    
    // MARK: - Outlets
    @IBOutlet weak var startRouteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: friendLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = friendLocation
        annotation.title = friendEmail
        mapView.addAnnotation(annotation)
        
    }
    
    
    
}
