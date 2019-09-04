//
//  ChatLogController.swift
//  Chatt
//
//  Created by Diana Oros on 8/9/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user : UsersModel? {
        didSet {
            navigationItem.title = user?.name
            
            retrieveMessages()
        }
    }
    
    let cellId = "cellID"
    var messagesArray = [MessagesModel]()
    var containerViewBottomAnchor : NSLayoutConstraint?
    var startingFrame : CGRect?
    var blackBackgroundView : UIView?
    var startingImageView : UIImageView?
    
    lazy var messageInputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var sendButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        
//        setupInputsComponents()
//        setupKeyboardObserver()
        keyboardObserver()
        
    }
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        containerView.backgroundColor = .white
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 200/225, green: 200/225, blue: 200/225, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImageTapped)))
        
        containerView.addSubview(sendButton)
        containerView.addSubview(messageInputTextField)
        containerView.addSubview(separatorLineView)
        containerView.addSubview(uploadImageView)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        messageInputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        messageInputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageInputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageInputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
//        let textField = UITextField()
//        textField.placeholder = "Message"
//
//        containerView.addSubview(textField)
//
//        textField.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func handleUploadImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("we selected an image")
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let userMessageImage = NSUUID().uuidString
        let imageReference = Storage.storage().reference().child("Message_Images").child("\(userMessageImage).jpg")
        if let uploadData = image.jpegData(compressionQuality: 0.02) {
            imageReference.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Error uploading image to Firebase Storage", error!)
                } else {
                    imageReference.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("Error downloading url", error!)
                        } else if let imageURL = url?.absoluteString {
                            self.sendMessageWithImageURL(imageURL: imageURL, image: image)
                            
                        }
                    })
                }
            }
        }
    }
    

    
    func setupInputsComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(messageInputTextField)
        
        messageInputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        messageInputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageInputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageInputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 200/225, green: 200/225, blue: 200/225, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    @objc func handleSend() {
        let properties : [String : AnyObject] = ["text": messageInputTextField.text! as AnyObject]
        sendMessagesWithProperties(properties: properties)
    }
    
    func sendMessageWithImageURL(imageURL: String, image: UIImage) {
        let properties : [String : AnyObject] = ["imageURL": imageURL as AnyObject,
                                                 "imageWidth": image.size.width as AnyObject,
                                                 "imageHeight": image.size.height as AnyObject]
        sendMessagesWithProperties(properties: properties)
    }
    
    private func sendMessagesWithProperties(properties: [String : AnyObject]) {
        messageInputTextField.endEditing(true)
        messageInputTextField.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let receiverID = user!.id!
        let receiverEmail = user!.email
        let senderID = Auth.auth().currentUser?.uid
        let senderEmail = Auth.auth().currentUser?.email
        let timestamp : NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var messagesDictionary = ["receiverID": receiverID,
                                  "receiverEmail": receiverEmail as Any,
                                  "senderID": senderID as Any,
                                  "senderEmail": senderEmail as Any,
                                  "timestamp": timestamp] as [String : Any]
        //append properties from handleSend and sendMessageWithImageURL to this messageDictionary
        //key = $0, value = $1
        properties.forEach({messagesDictionary[$0] = $1})
        
        messagesDB.childByAutoId().setValue(messagesDictionary) {
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved succesfully into Firebase database.")
                
                guard let messageID = reference.key else {
                    return
                }
                
                let senderMessagesReference = Database.database().reference().child("User-Messages").child(senderID!).child(receiverID)
                senderMessagesReference.updateChildValues([messageID : 1])
                
                let receiverMessagesReference = Database.database().reference().child("User-Messages").child(receiverID).child(senderID!)
                receiverMessagesReference.updateChildValues([messageID : 1])
                
                self.messageInputTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageInputTextField.text = ""

            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messagesArray[indexPath.item]
        cell.messageTextView.text = message.text
        cell.chatLogController = self
        
        if let text = message.text {
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.messageTextView.isHidden = false
        } else if message.imageURL != nil {
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.messageTextView.isHidden = true
        }
        
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: MessagesModel) {
        if let profileImageURL = self.user?.profileImageURL {
            cell.profileImageView.loadImagesUsingCacheWithURLString(urlString: profileImageURL)
        }
        
        if message.senderID == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.messageTextView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.messageTextView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageURL = message.imageURL {
            cell.messageImageView.loadImagesUsingCacheWithURLString(urlString: messageImageURL)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        let message = messagesArray[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
            //200 comes from bubbleViewWidthAnchor.constant set to 200 in cellForItemAt
        }
//        return CGSize(width: view.frame.width, height: height)
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func retrieveMessages() {
        guard let currentUserUID = Auth.auth().currentUser?.uid, let receiverID = user?.id else {
            return
        }
        
        let userMessagesReference = Database.database().reference().child("User-Messages").child(currentUserUID).child(receiverID)
        userMessagesReference.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesReference = Database.database().reference().child("Messages").child(messageID)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
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
//                if let image = dictionary["imageURL"] {
//                    message.imageURL = image as? String
//                }
//                if let imageWidth = dictionary["imageWidth"] {
//                    message.imageWidth = imageWidth as? NSNumber
//                }
//
//                if let imageHeight = dictionary["imageHeight"] {
//                    message.imageHeight = imageHeight as? NSNumber
//                }
//
//                message.receiverID = receiverID as? String
//                message.receiverEmail = receiverEmail as? String
//                message.senderID = senderID as? String
//                message.senderEmail = senderEmail as? String
//                message.timestamp = timestamp as? NSNumber

                
//                if message.chatPartnerID() == self.user?.id {
                    self.messagesArray.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.scrollToLastIndex()
                    }
//                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func performZoomInForStartingImageView(startingImageView : UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
                
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
                
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // h2 / w1 = h1 / w2
                // h2 = h1 / w1 * w2
                let zoomingImageViewHeight = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: zoomingImageViewHeight)
                zoomingImageView.center = keyWindow.center
                
            }) { (completed) in
                //done
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func keyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        scrollToLastIndex()
    }
    
    func scrollToLastIndex() {
        if messagesArray.count > 0 {
            let indexPath = NSIndexPath(item: self.messagesArray.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
    
//    func setupKeyboardObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc func handleKeyboardWillShow(notification: Notification) {
//        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
////        print(keyboardFrame?.height)
//        containerViewBottomAnchor?.constant = -keyboardFrame!.height
//        UIView.animate(withDuration: keyboardDuration) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    @objc func handleKeyboardWillHide(notification: Notification) {
//        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: keyboardDuration) {
//            self.view.layoutIfNeeded()
//        }
//    }
    

    

    
    //TODO:  Configure messageTextField height for longer messages
    
    //1. adopt Uitextfielddelegate
    //2. set messageinputtextfield as delegate
    //3.use textfielddidbeginediting
    
    //TODO: Configure keyboard size and container with message and sendButton to appear above keyboard
    
}




