//
//  FriendsViewController.swift
//  RoadTrip
//
//  Created by Sarin Swift on 12/5/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit
import CoreLocation

struct Names {
    var title: String
}

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var friends = [DataSnapshot]()
    
    @IBOutlet weak var tableView: UITableView!
    var locationManager = CLLocationManager()
    var personLocation = CLLocationCoordinate2D()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
        Database.database().reference().child("AddUsers").observe(.childAdded) { (snapshot) in
            // insert code for when there is a driver
//            if let friendsRequestDict = snapshot.value as? [String: AnyObject] {
//                if let driverLat = friendsRequestDict["driverLat"] {
//
//                }
//            } else {
//                self.friends.append(snapshot)
//                self.tableView.reloadData()
//            }
            self.friends.append(snapshot)
            self.tableView.reloadData()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // update the friends location every 3 seconds in the table view
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.4784313725, alpha: 1)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // popup action to add name, latitude, and loingitude
//    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
//
//        let alert = UIAlertController(title: "Add Location", message: "Input latitude and longitude", preferredStyle: .alert)
//
//        // adding name, latitude, longitude
//        alert.addTextField(configurationHandler: usrNameTextField)
//        alert.addTextField(configurationHandler: latitudeTextField)
//        alert.addTextField(configurationHandler: longitudeTextField)
//
//        var addAction = UIAlertAction()
//        addAction = UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0]
//            let textField1 = alert?.textFields![1]
//            let textField2 = alert?.textFields![2]
//            print("Text field: \(textField?.text as Optional)")
//            print("Text field: \(textField1?.text as Optional)")
//            print("Text field: \(textField2?.text as Optional)")
//
//            // want to insert it to the array of names
//            self.names.append(Names(title: textField?.text ?? ""))
//            let indexPath = IndexPath(row: self.names.count - 1, section: 0)
//            self.tableView.beginUpdates()
//            self.tableView.insertRows(at: [indexPath], with: .automatic)
//            self.tableView.endUpdates() })
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
//            let textField = alert?.textFields![0]
//            print("Text field: \(textField?.text as Optional)")})
//        alert.addAction(cancelAction)
//        alert.addAction(addAction)
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func cancelTripButtonTapped(_ sender: UIButton) {
        
        // user gets removed out of that trip
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("AddUsers").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("AddUsers").removeAllObservers() 
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! FriendsTableViewCell
        
        let snapshot = friends[indexPath.row]
        if let friendsDictionary = snapshot.value as? [String: AnyObject] {
            if let email = friendsDictionary["email"] as? String {
                if let lat = friendsDictionary["lat"] as? Double {
                    if let lon = friendsDictionary["lon"] as? Double {
                        
                        let personCLLocation = CLLocation(latitude: personLocation.latitude, longitude: personLocation.longitude)
                        let friendCLLoctaion = CLLocation(latitude: lat, longitude: lon)
                        
                        let distance = personCLLocation.distance(from: friendCLLoctaion) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        
                        cell.name.text = "\(email) - \(roundedDistance)km away"
                        cell.name.textColor = .white
                    }
                }
            }
        }
        
        cell.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.4784313725, alpha: 1)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = friends[indexPath.row]
        performSegue(withIdentifier: "toMapViewController", sender: snapshot)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            personLocation = coord
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? MapViewController {
            if let snapshot = sender as? DataSnapshot {
                
                if let friendsDictionary = snapshot.value as? [String: AnyObject] {
                    if let email = friendsDictionary["email"] as? String {
                        if let lat = friendsDictionary["lat"] as? Double {
                            if let lon = friendsDictionary["lon"] as? Double {
                                
                                mapViewController.friendEmail = email
                                
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                mapViewController.friendLocation = location
                                
                                mapViewController.driverLocation = personLocation
                                
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    
    
    
    
}

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
}
