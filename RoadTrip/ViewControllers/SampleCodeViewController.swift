//
//  SampleCodeViewController.swift
//  RoadTrip
//
//  Created by Rinni Swift on 12/10/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit
import CoreLocation

class SampleCodeViewController: UIViewController {
    
    // add current user to the database
    // information saved:
    // - email, latitude, and longtitude
    
    // ERRORS: userLocation is of type CLLocationCoordinate2D in the ViewController swift file.
    
//    @IBAction func addFriendButtonTapped(_ sender: UIButton) {
//        if let email = Auth.auth().currentUser?.email {
//            // get the coordinates of the user
//            let userInRide: [String: Any] = ["email": email, "lat": userLocation.latitude, "lon": userLocation.longitude]
//            Database.database().reference().child("AddUsers").childByAutoId().setValue(userInRide)
//            print("added users location and email to firebase.")
//        }
//    }
//
//    @IBAction func removeUserFromTrip(_ sender: UIButton) {
//        if let email = Auth.auth().currentUser?.email {
//            Database.database().reference().child("AddUsers").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
//                snapshot.ref.removeValue()
//                Database.database().reference().child("AddUsers").removeAllObservers()
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
