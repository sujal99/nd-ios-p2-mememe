//
//  ImagetoDataTransformer.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 11/01/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit

@objc(ImagetoDataTransformer)
class ImagetoDataTransformer: ValueTransformer {
  
  override class func transformedValueClass() -> Swift.AnyClass {
    return self
  }
  
  override class func allowsReverseTransformation() -> Bool {
    return true
  }
  
  override func transformedValue(_ value: Any?) -> Any? {
    guard let pngImg = value as? UIImage else {
      return nil
    }
    return UIImagePNGRepresentation(pngImg)
  }
  
  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard  let pngData = value as? Data else {
      return nil
    }
    return UIImage(data: pngData)
  }
  
}
