//
//  ViewController.swift
//  Chatt
//
//  Created by Diana Oros on 7/17/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var messagesArray = [MessagesModel]()
    var messageDictionary = [String : MessagesModel]()
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        checkIfUserIsLoggedIn()
//        observeMessages()
//        observeUserMessages()
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
            print("Error: there was an error signing out")
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            retrieveUserAndSetupNavBarTitle()
        }
    }
    
    func retrieveUserAndSetupNavBarTitle() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("Users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? Dictionary<String,String> {
//                self.navigationItem.title = dictionary["name"] as? String
                
                let userName = dictionary["name"]!
                let userProfileImage = dictionary["profileImageURL"]!
                
                let user = UsersModel()
                user.name = userName
                user.profileImageURL = userProfileImage

                self.setupNavBarWithUser(user: user)
            }
        }   
    }
    
    func setupNavBarWithUser(user: UsersModel) {
//        navigationItem.title = user.name
        messagesArray.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()

        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        titleView.backgroundColor = UIColor.red

        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let profileImageURL = user.profileImageURL {
             profileImageView.loadImagesUsingCacheWithURLString(urlString: profileImageURL)
        } else {
            print("Error getting user image.")
        }

        let userNameLabel = UILabel()
        userNameLabel.text = user.name
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(userNameLabel)
        
        self.navigationItem.titleView = titleView
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
//        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
//        self.navigationController?.navigationBar.isUserInteractionEnabled = true

    }
    
    @objc func showChatControllerForUser(user : UsersModel) {
//        print("Title View tapped")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        navController.navigationBar.barTintColor = UIColor.white
    }
    
    func observeUserMessages() {
        //observe current user uid node
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }

        let userMessagesReference = Database.database().reference().child("User-Messages").child(currentUserUID)
        userMessagesReference.observe(.childAdded, with: { (snapshot) in
        //observe partner ID node
            let partnerID = snapshot.key
            let partnerIDMessageReference = Database.database().reference().child("User-Messages").child(currentUserUID).child(partnerID)
            partnerIDMessageReference.observe(.childAdded, with: { (snapshot) in

        //observe message id node
                let messageID = snapshot.key
                self.fetchMessagesWithMessageID(messageID: messageID)
                
            }, withCancel: nil)
            
//            partnerIDMessageReference.observe(.childRemoved, with: { (snapshot) in
//                print(snapshot)
//                print(self.messageDictionary)
//                self.messageDictionary.removeValue(forKey: snapshot.key)
//                self.attemptReloadOfTable()
//
//            }, withCancel: nil)
            
        }, withCancel: nil)
        
        userMessagesReference.observe(.childRemoved, with: { (snapshot) in
            print(snapshot)
            print(self.messageDictionary)
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
        
        

    }
    
    private func fetchMessagesWithMessageID(messageID : String) {
        let messagesReference = Database.database().reference().child("Messages").child(messageID)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            //observe messages
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let message = MessagesModel(dictionary: dictionary)
                
//                let receiverID = dictionary["receiverID"]!
//                let receiverEmail = dictionary["receiverEmail"]!
//                let senderID = dictionary["senderID"]!
//                let senderEmail = dictionary["senderEmail"]!
//                let timestamp = dictionary["timestamp"]!
//                
//                if let text = dictionary["text"] {
//                    message.text = text as? String
//                }
//                
//                message.receiverID = receiverID as? String
//                message.receiverEmail = receiverEmail as? String
//                message.senderID = senderID as? String
//                message.senderEmail = senderEmail as? String
//                message.timestamp = timestamp as? NSNumber
                
                
                //                self.messagesArray.append(message)
                if let chatPartnerID = message.chatPartnerID() {
                    self.messageDictionary[chatPartnerID] = message
                    
                }
                self.attemptReloadOfTable()
                
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        print("We canceled our timer")
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        print("scheduled a table reload in 0.05 sec")
    }
    
    @objc func handleReloadTable() {
        self.messagesArray = Array(self.messageDictionary.values)
        
        self.messagesArray.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            print("We reloaded user messages data")
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messagesArray[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messagesArray[indexPath.row]
        
        guard let chatPartnerID = message.chatPartnerID() else {
            return
        }
        let ref = Database.database().reference().child("Users").child(chatPartnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
            
            let user = UsersModel()
            guard let dictionary = snapshot.value as? [String : String] else {
                return
            }
            let userName = dictionary["name"]!
            let userEmail = dictionary["email"]!
            let userProfileImage = dictionary["profileImageURL"]!
            
            user.name = userName
            user.email = userEmail
            user.profileImageURL = userProfileImage
            user.id = chatPartnerID

            self.showChatControllerForUser(user: user)
        
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        let message = messagesArray[indexPath.row]
        
        if let chatPartnerID = message.chatPartnerID() {
            Database.database().reference().child("User-Messages").child(currentUserUID).child(chatPartnerID).removeValue { (error, reference) in
                if error != nil {
                    print("Error deleting messages: ", error!)
                } else {
                    self.messageDictionary.removeValue(forKey: chatPartnerID)
                    self.attemptReloadOfTable()
                }
            }
        }
    }

    
    
    
    
}

