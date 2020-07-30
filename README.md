CHATT

The Chatt app is a iMessage like app built in Swift using Xcode. The iOS Deployment Target is 12.2.

The project can be downloaded or cloned and it requires Cocoapods installation in order to build and run the project. It also requires a Firebase account in order to write data. The app can be played on Xcode's Simulator.

The purpose of the app is to write to a database, retrieve information from the database, register users, send video and image messages, cache information, perform networking requests.

The project utilizes Google's Firebase to authenticate users (create and sign in), Firebase Database to store and retrieve messages, and Firebase Storage to save and retrieve User's profile image, but also video and image messages sent between users.

The app's UI was created in code rather than Interface Builder because I wanted to practice how to create, update and maintain the UI programmatically.  

The app uses UIKit, MobileCoreServices, AVFoundation, NSCache, URLSession, UITableViewControllers, UICollectionViewController, UICollectionViewCell, UIImagePickerController, UINavigationController, UITextField and more.

Currently some View code needs to be updated to follow MVC design pattern. 
The code also needs to be update with access control. 


Here is how the app looks to the end user:

![Login screen](/README_images/chatt_login.png)
![Signup screen](/README_images/chatt_signup.png)
![My messages screen](/README_images/chatt__my_messages_list.png)
![Write a message screen](/README_images/chatt_write_message.png)
![Message screen](/README_images/chatt_message1.png)
![List of users screen](/README_images/chatt_list_of_users.png)
