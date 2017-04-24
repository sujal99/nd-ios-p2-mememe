//
//  ImageHandler.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 23/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit


struct ImageHandler {
  static let dateFormatter: DateFormatter = {
    var df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    return df
  }()
  
  static let imageDirectory: String = {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    return docPath
  }()
  
  func saveImages(originalImage: UIImage, memedImage: UIImage, memedImageThumbnail: UIImage, timeStamp: Date) throws -> String {
    let fileName = ImageHandler.dateFormatter.string(from: timeStamp)
    let originalFileName = URL(fileURLWithPath:ImageHandler.imageDirectory.appendingFormat("/%@.png", fileName))
    let memedFileName = URL(fileURLWithPath:ImageHandler.imageDirectory.appendingFormat("/%@-memed.png", fileName))
    let memedThumbnailFileName = URL(fileURLWithPath:ImageHandler.imageDirectory.appendingFormat("/%@-thumb.png", fileName))
    try UIImagePNGRepresentation(originalImage)?.write(to: originalFileName, options: .atomic)
    try UIImagePNGRepresentation(memedImage)?.write(to: memedFileName, options: .atomic)
    try UIImagePNGRepresentation(memedImageThumbnail)?.write(to: memedThumbnailFileName, options: .atomic)
    return fileName
  }
  
  fileprivate func findImage(fullImagePath: String) -> UIImage? {
    if FileManager.default.fileExists(atPath: fullImagePath) {
      let img = UIImage(contentsOfFile: fullImagePath)
      return img
    }
    return nil
  }
  
  func originalImage(imageName: String) -> UIImage? {
    let originalFileName = ImageHandler.imageDirectory.appendingFormat("/%@.png", imageName)
    return findImage(fullImagePath:originalFileName)
  }
  
  func memedImage(imageName: String) -> UIImage? {
    let memedImageFileName = ImageHandler.imageDirectory.appendingFormat("/%@-memed.png", imageName)
    return findImage(fullImagePath:memedImageFileName)
  }
  
  func memedThumbnailImage(imageName: String) -> UIImage? {
    let memedImageFileName = ImageHandler.imageDirectory.appendingFormat("/%@-thumb.png", imageName)
    return findImage(fullImagePath:memedImageFileName)
  }
}
