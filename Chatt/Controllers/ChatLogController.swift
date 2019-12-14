//
//  ChatLogController.swift
//  Chatt
//
//  Created by Diana Oros on 8/9/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
        uploadImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
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
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            uploadToFirebaseStorageUsingVideoURL(url: videoURL)
        } else {
            handleImageSelectedWithInfo(info: info)
        }
        
        dismiss(animated: true, completion: nil)

    }
    private func handleImageSelectedWithInfo(info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage) { (imageURL) in
                self.sendMessageWithImageURL(imageURL: imageURL, image: selectedImage)
            }
        }
    }

    private func uploadToFirebaseStorageUsingVideoURL(url: URL) {
        if let thumbnailImage = thumbnailImageForFileURL(fileURL: url) {
            let userMessageVideo = NSUUID().uuidString
            let videoAlbumStorage = Storage.storage().reference().child("Message_Videos")
            let videoStorage = videoAlbumStorage.child("\(userMessageVideo).mov")
            let uploadTask = videoStorage.putFile(from: url, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Error uploading videos to Firebase Storage:", error!)
                } else {
                    videoStorage.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("Error downloading video url from firebase:", error!)
                        } else if let firebaseVideoURL = url?.absoluteString {
                            print("Here's the firebase video url:", firebaseVideoURL)
                            self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageURL) in
                                let properties : [String : AnyObject] = ["videoURL" : firebaseVideoURL as AnyObject,
                                                                         "imageWidth" : thumbnailImage.size.width as AnyObject,
                                                                         "imageHeight" : thumbnailImage.size.height as AnyObject,
                                                                         "imageURL": imageURL as AnyObject]
                            
                                self.sendMessagesWithProperties(properties: properties)
                            })
                        }
                    })
                }
            }

            uploadTask.observe(.progress) { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUnitCount = snapshot.progress?.totalUnitCount {
                    let uploadPercentage = completedUnitCount * 100 / totalUnitCount
//                self.navigationItem.title = String(completedUnitCount)
                    self.navigationItem.title = "Loading " + String(uploadPercentage) + "%"
                }
            }
        
            uploadTask.observe(.failure) { (snapshot) in
                self.navigationItem.title = "Poor connection. Please try again"
            }

            uploadTask.observe(.success) { (snapshot) in
                self.navigationItem.title = self.user?.name
            }
        }
    }
    
    private func thumbnailImageForFileURL(fileURL: URL) -> UIImage? {
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (String) -> ()) {
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
                            completion(imageURL)
//                            self.sendMessageWithImageURL(imageURL: imageURL, image: image)
                            
                        }
                    })
                }
            }
        }
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
        cell.message = message
        
        if let text = message.text {
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.messageTextView.isHidden = false
        } else if message.imageURL != nil {
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.messageTextView.isHidden = true
        }
        if message.videoURL != nil {
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        
        //does the same as:
//        cell.playButton.isHidden = message.videoURL == nil
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
                    self.messagesArray.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.scrollToLastIndex()
                    }
                
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
    
}




