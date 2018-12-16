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
    var driverLocation = CLLocationCoordinate2D()
    var friendEmail = ""
    
    // MARK: - Outlets
    @IBOutlet weak var startRouteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        // updating yourself onto same database as friend
        Database.database().reference().child("AddUsers").queryOrdered(byChild: "email").queryEqual(toValue: friendEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLon": self.driverLocation.longitude])
            Database.database().reference().child("AddUsers").removeAllObservers()
        }
        
        // give directions
        // this is going to open up the map app
        let friendCLLocation = CLLocation(latitude: self.friendLocation.latitude, longitude: self.friendLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(friendCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.friendEmail
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: friendLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = friendLocation
        annotation.title = friendEmail
        mapView.addAnnotation(annotation)
        
        displayDriverAndFriend()
        
    }
    
    func displayDriverAndFriend() {
//        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
//        let friendCLLocation = CLLocation(latitude: friendLocation.latitude, longitude: friendLocation.longitude)
        mapView.removeAnnotations(mapView.annotations)
        
        let latDelta = abs(driverLocation.latitude - friendLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - friendLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: driverLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        mapView.setRegion(region, animated: true)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Your Location"
        mapView.addAnnotation(driverAnno)
        
        let friendAnno = MKPointAnnotation()
        friendAnno.coordinate = friendLocation
        friendAnno.title = "Friends Location"
        mapView.addAnnotation(friendAnno)
    }
    
    
    
    
}
