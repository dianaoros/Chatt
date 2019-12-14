//
//  MessagesModel.swift
//  Chatt
//
//  Created by Diana Oros on 8/14/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class MessagesModel: NSObject {

    var receiverEmail : String?
    var receiverID : String?
    var senderEmail : String?
    var senderID : String?
    var timestamp : NSNumber?
    var text : String?
    var imageURL : String?
    var imageWidth: NSNumber?
    var imageHeight : NSNumber?
    var videoURL : String?
    
    func chatPartnerID() -> String? {
        if senderID == Auth.auth().currentUser?.uid {
            return receiverID
        } else {
            return senderID
        }
        // Can also be written on one line :
//         return senderID == Auth.auth().currentUser?.uid ? receiverID : senderID
    }
    
    init(dictionary: [String : AnyObject]) {
        super.init()
        
        receiverID = dictionary["receiverID"] as? String
        receiverEmail = dictionary["receiverEmail"] as? String
        senderID = dictionary["senderID"] as? String
        senderEmail = dictionary["senderEmail"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        text = dictionary["text"] as? String
        imageURL = dictionary["imageURL"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoURL = dictionary["videoURL"] as? String
    }

}
