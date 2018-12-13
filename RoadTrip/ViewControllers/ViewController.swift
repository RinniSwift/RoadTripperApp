//
//  ViewController.swift
//  RoadTrip
//
//  Created by Sarin Swift on 10/27/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

// anything that conforms to this protocol has to implement this method
protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}
 
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var steps = [MKRoute.Step]()
    var resultsSearchController: UISearchController? = nil
    // cahcing any incoming placemarks
    var selectedPin: MKPlacemark? = nil
    var geoFire: GeoFire!
    
    // bool if user is currently in a road trip                                 !Not used yet!
    // userInTrip should be true when user adds an friend in the trip
    var userInTrip = false

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // this requests to use location even outside of the app
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupSearchBar()

    }
    
    @IBOutlet weak var addFriendButton: UIBarButtonItem!
    @IBAction func addFriendButtonTapped(_ sender: UIBarButtonItem) {
        print("add freind button tapped")
                // get the current users email
        if let email = Auth.auth().currentUser?.email {
            // get the coordinates of the user
            let userInRide: [String: Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
            Database.database().reference().child("AddUsers").childByAutoId().setValue(userInRide)
            print("added users location and email to firebase.")
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let linkingVC = storyBoard.instantiateViewController(withIdentifier: "FriendsViewController")
        self.navigationController?.present(linkingVC, animated: true, completion: nil)
    }
    
    
//    @IBAction func addFriendButtonTapped(_ sender: UIBarButtonItem) {
//
//        print("add freind button tapped")
//        // get the current users email
//        if let email = Auth.auth().currentUser?.email {
//            // get the coordinates of the user
//            let userInRide: [String: Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
//            Database.database().reference().child("AddUsers").childByAutoId().setValue(userInRide)
//            print("added users location and email to firebase.")
//        }
//
//    }
    
    // Called everytime our user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinates = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            mapView.userTrackingMode = .followWithHeading
            mapView.showsUserLocation = true
        }
        
//        let location = locations[0]
//        // how much we want our app to be zoomed in on the location
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        // getting the current location
//        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
//        mapView.setRegion(region, animated: true)
//        mapView.userTrackingMode = .followWithHeading
//
//        // this shows the blue dot on the map
//        self.mapView.showsUserLocation = true
        
    }
    
    // function called in dropPinZoomIn()
    func getDirections(to toLocation: CLLocationCoordinate2D) {
        guard let fromLocation = locationManager.location?.coordinate else {
            return
        }
        let request = createDirectionsRequest(from: fromLocation, to: toLocation)
        let directions = MKDirections(request: request)
        
        // now that we have directions with the route, now we will calculate that gives us back a response and an error
        directions.calculate { [unowned self] (response, error) in
            // TODO: error handling
            guard let response = response else { return /* TODO: show response not available in alert*/ }
            // the routes come in array of routes. So we need to iterate through all the possible routes
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                // boundingMapRect will fit the entire route into the screen
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            // ADDINGGGGGG
            
            // probably means getting the first route in the many routes they chose for us
//            guard let primaryRoute = response.routes.first else { return }
//            self.steps = primaryRoute.steps
//            for i in 0..<primaryRoute.steps.count {
//                let step = primaryRoute.steps[i]
//                print(step.instructions)
//                print(step.distance)
//                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
//            }
        }
    }
    
    // helper method to return a request
    func createDirectionsRequest(from fromCooridinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        
        mapView.removeOverlays(mapView.overlays)
        
        let startingLocation = MKPlacemark(coordinate: fromCooridinate)
        // coordinate of the center of the map
        let destination = MKPlacemark(coordinate: toCoordinate)
        
        
        let request = MKDirections.Request()
        // source is the starting point
        // destination is where we wanna get to
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    
    func setupSearchBar() {
        
        // creates the search controller
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultsSearchController?.searchResultsUpdater = locationSearchTable

        
        // Setting up the search bar
        let searchBar = resultsSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        // embeds the search bar within the navigation bar
        navigationItem.titleView = resultsSearchController?.searchBar
        
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        // handles the mapView on to the location search table
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
    }

}

extension ViewController: HandleMapSearch, MKMapViewDelegate {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins so we make sure that we're only dealing with one pin on the map
        mapView.removeAnnotations(mapView.annotations)
        
        // a map view that contains a coordinate, title, and subtitle
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        // zooms the map to the coordinate
        mapView.setRegion(region, animated: true)
        
        // draw the directions
        getDirections(to: selectedPin!.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        
        return renderer
    }
    
    
}

