//
//  Meme+CoreDataClass.swift
//  
//
//  Created by Sujal Ghosh on 11/01/17.
//
//

import UIKit
import CoreData


public class Meme: NSManagedObject {
  fileprivate var _memedImageThumbnail: UIImage?
  var memedImageThumbnail: UIImage? {
    get {
      if let imageName = imageName, _memedImageThumbnail == nil {
        _memedImageThumbnail = imageHandler.memedThumbnailImage(imageName: imageName)
      }
      return _memedImageThumbnail
    }
    set(newMemedImageThumbnail) {
      _memedImageThumbnail = newMemedImageThumbnail
    }
  }
  
  var memedImage: UIImage? {
    get {
      if let imageName = imageName {
        return imageHandler.memedImage(imageName: imageName)
      }
      return nil
    }
  }
  
  var originalImage: UIImage? {
    get {
      if let imageName = imageName {
        return imageHandler.originalImage(imageName: imageName)
      }
      return nil
    }
  }
  
  var imageHandler: ImageHandler!
  
  func saveImages (originalImage: UIImage, memedImage: UIImage, memedImageThumbnail: UIImage, timeStamp: Date) {
    imageName = try? imageHandler.saveImages(originalImage: originalImage, memedImage: memedImage, memedImageThumbnail: memedImageThumbnail, timeStamp: timeStamp)
  }
  
  public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
    super.init(entity: entity, insertInto: context)
    self.imageHandler = ImageHandler()
  }
}
