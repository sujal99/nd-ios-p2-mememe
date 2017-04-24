//
//  UIImage+Meme.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 23/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit

/*
 https://gist.github.com/djbriane/160791
 */
extension UIImage {
  class func generatePhotoThumbnail(image: UIImage) -> UIImage? {
    let width: CGFloat = 80
    let height = image.size.height / image.size.width * width
    let size = CGSize(width: width, height: height)
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: CGPoint.zero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
}
