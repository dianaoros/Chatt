//
//  NewMessageController.swift
//  Chatt
//
//  Created by Diana Oros on 7/24/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    var userArray : [UsersModel] = [UsersModel]()
    var messagesController = MessagesController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        retrieveUsers()

    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    func retrieveUsers() {
        let usersDB = Database.database().reference().child("Users")
        usersDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let userName = snapshotValue["name"]!
            let userEmail = snapshotValue["email"]!
            let userProfileImage = snapshotValue["profileImageURL"]!
            
            let user = UsersModel()
            user.name = userName
            user.email = userEmail
            user.profileImageURL = userProfileImage
            user.id = snapshot.key
            
            self.userArray.append(user)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = userArray[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let userImageURL = user.profileImageURL {
            cell.profileImageView.loadImagesUsingCacheWithURLString(urlString: userImageURL)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("View Controller dismissed successfully")
            let user = self.userArray[indexPath.row]
            self.messagesController.showChatControllerForUser(user: user)
        }
    }

}

