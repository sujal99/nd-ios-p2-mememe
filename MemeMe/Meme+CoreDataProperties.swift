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
    return NSManagedObject(entity: entityDesc, insertInto: managedObjectContext) as? Meme
  }
  
  @NSManaged public var timeStamp: Date?
  @NSManaged public var topText: String?
  @NSManaged public var bottomText: String?
  @NSManaged public var image: UIImage?
  @NSManaged public var memedImage: UIImage?

}
