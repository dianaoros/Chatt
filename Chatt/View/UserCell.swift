//
//  UserCell.swift
//  Chatt
//
//  Created by Diana Oros on 8/16/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message : MessagesModel? {
        didSet {
            setupMessageNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    private func setupMessageNameAndProfileImage() {

        if let id = message?.chatPartnerID() {
            let reference = Database.database().reference().child("Users").child(id)
            reference.observe(.value, with: { (snapshot) in
//                print(snapshot)
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageURL = dictionary["profileImageURL"] as? String {
                        self.profileImageView.loadImagesUsingCacheWithURLString(urlString: profileImageURL)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super .layoutSubviews()
        setupUserTextLabelConstraints()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        setupProfileImageViewConstraints()
        setupTimeLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProfileImageViewConstraints() {
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    func setupTimeLabelConstraints() {
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        if textLabel == nil {
//            timeLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//        } else {
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
//        }
    }
    
    func setupUserTextLabelConstraints() {
        textLabel?.frame = CGRect(x: 64, y: ((textLabel?.frame.origin.y)! - 2), width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: ((detailTextLabel?.frame.origin.y)! + 2), width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    
}
