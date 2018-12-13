//
//  ProfileViewController.swift
//  RoadTrip
//
//  Created by Rinni Swift on 12/12/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ProfileViewController: UIViewController {
    

    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        // remove user out of current trip
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("AddUsers").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("AddUsers").removeAllObservers()
            }
        }
        
        // sign user out
        try? Auth.auth().signOut()
        
        // bring user to the front page
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
