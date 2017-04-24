//
//  Meme+CoreDataProperties.swift
//  
//
//  Created by Sujal Ghosh on 11/01/17.
//
//

import UIKit
import CoreData


extension Meme {
  
  @nonobjc public class func sortedFetchRequest() -> NSFetchRequest<Meme> {
    let req = NSFetchRequest<Meme>(entityName: "Meme")
    req.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
    return req
  }
  
  @nonobjc public class func meme(_ managedObjectContext: NSManagedObjectContext) -> Meme? {
    guard let entityDesc = NSEntityDescription.entity(forEntityName: "Meme", in: managedObjectContext) else {
      return nil
    }
    let meme = Meme(entity: entityDesc, insertInto: managedObjectContext)
    meme.imageHandler = ImageHandler()
    return meme
  }
  
  @NSManaged public var timeStamp: Date?
  @NSManaged public var topText: String?
  @NSManaged public var bottomText: String?
  @NSManaged public var imageName: String?
}
