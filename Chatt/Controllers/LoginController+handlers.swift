//
//  LoginController+handlers.swift
//  Chatt
//
//  Created by Diana Oros on 7/24/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func selectProfileImageWhenSigningUp() {
        print("profile image tapped")
        let imagePicker = UIImagePickerController()
        present(imagePicker, animated: true, completion: nil)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            logoImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    @objc func handleRegister() {
        guard let userEmail = emailTextField.text, let userPassword = passwordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let userProfileImage = logoImageView.image else {
            print("Sign up fields are not valid")
            return
        }
        
        //create users
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let userUID = user?.user.uid else {
                return
            }
            
            let userFirebaseImageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("Profile_Images").child("\(userFirebaseImageName).jpg")
            if let uploadData = userProfileImage.jpegData(compressionQuality: 0.08) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print("Error downloading url.", error!)
                            } else {
                                if let profileImageURL = url?.absoluteString {
                                    let values = ["name" : firstName + " " + lastName, "email" : userEmail, "profileImageURL" : profileImageURL]
                                    self.registerUserIntoDatabaseWithUID(userUID: userUID, values: values as [String : AnyObject])
                                } else {
                                    print("Error registering user to database", error!)
                                }
                            }
                        })
                    }
                })
            }

        }
        
    }
    
    private func registerUserIntoDatabaseWithUID(userUID : String, values : [String : AnyObject]) {
        let ref = Database.database().reference().child("Users").child(userUID)
        ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                print("Error saving users into Firebase database")
            } else {
                print("Saved user succesfully into Firebase database")
//                self.messagesController?.navigationItem.title = values["name"] as? String
                
                //setting nav bar title
                let user = UsersModel()
                let userName = values["name"]
                let userProfileImage = values["profileImageURL"]

                user.name = userName as? String
                user.profileImageURL = userProfileImage as? String
                
                self.messagesController?.setupNavBarWithUser(user: user)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}
