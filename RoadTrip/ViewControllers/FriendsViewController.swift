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

struct Names {
    var title: String
}

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var friends = [DataSnapshot]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            self.friends.append(snapshot)
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
    
    
//    func usrNameTextField(textField: UITextField!) {
//        textField.placeholder = "Name"
//    }
//    func latitudeTextField(textField: UITextField) {
//        textField.placeholder = "Latitude"
//    }
//    func longitudeTextField(textField: UITextField) {
//        textField.placeholder = "Longitude"
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! FriendsTableViewCell
        
        let snapshot = friends[indexPath.row]
        if let friendsDictionary = snapshot.value as? [String: AnyObject] {
            if let email = friendsDictionary["email"] as? String {
                cell.name.text = email
                cell.name.textColor = .white
            }
        }
        
        
        
        cell.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.4470588235, blue: 0.4784313725, alpha: 1)
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected index: \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            names.remove(at: indexPath.row)
//
//            self.tableView.beginUpdates()
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.endUpdates()
//        }
    }
    
}

class FriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
}
