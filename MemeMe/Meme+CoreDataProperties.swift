//
//  Meme+CoreDataProperties.swift
//  
//
//  Created by Sujal Ghosh on 11/01/17.
//
//

import Foundation
import CoreData


extension Meme {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Meme> {
    return NSFetchRequest<Meme>(entityName: "Meme");
  }
  
  @nonobjc public class func meme(_ managedObjectContext: NSManagedObjectContext) -> Meme? {
    guard let entityDesc = NSEntityDescription.entity(forEntityName: "Meme", in: managedObjectContext) else {
      return nil
    }
    return NSManagedObject(entity: entityDesc, insertInto: managedObjectContext) as? Meme
  }
  
  
  @NSManaged public var topText: String?
  @NSManaged public var bottomText: String?
  @NSManaged public var image: NSObject?
  @NSManaged public var memedImage: NSObject?
  
}
