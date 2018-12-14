//
//  LoginViewController.swift
//  RoadTrip
//
//  Created by Rinni Swift on 12/8/18.
//  Copyright © 2018 sarinswift. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        // remove user out of current trip
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("AddUsers").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("AddUsers").removeAllObservers()
            }
        }
        
        // sign user out
        try? Auth.auth().signOut()
    }
    
    // MARK: Actions
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        // sends alert if text fields are empty
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "Please provide a valid email and password for your account.")
        } else {
            // sign in to the account
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            // success sign in
                            print("sign in succed!")
                            self.performSegue(withIdentifier: "loginToMap", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        
        // alert if text fields are empty
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "Please provide both an email and password for your account.")
        }
        
        if let email = emailTextField.text {
            
            // check if password is more than 6 characters ***check if email is rigth format
            if (passwordTextField.text?.count)! >= 6 {
                print("password more than 6 characters")
                if let password = passwordTextField.text {
                    Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
//                        guard let user = authResult?.user else { return }
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            // success account created
                            Database.database()
                            self.performSegue(withIdentifier: "loginToMap", sender: nil)
                        }
                    }
                    
                    // add users email to the 'Users' in Firebase
                    let newUsers: [String: String] = ["email": email]
                    Database.database().reference().child("Users").childByAutoId().setValue(newUsers)
                    
                }
            } else {
                // display alert if password is less than 6 characters long
                displayAlert(title: "Error", message: "The password must be 6 characters long or more.")
            }
        }
        
    }
    
    // MARK: Functions
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
