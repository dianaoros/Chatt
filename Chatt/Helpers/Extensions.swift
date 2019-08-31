//
//  Extensions.swift
//  Chatt
//
//  Created by Diana Oros on 8/8/19.
//  Copyright © 2019 Diana Oros. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImagesUsingCacheWithURLString(urlString : String) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
        } else {
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                            self.image = downloadedImage
                        }
                    }
                }
            }.resume()
        }
    }
    
    
}

