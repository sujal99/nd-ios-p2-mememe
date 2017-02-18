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

    @NSManaged public var topText: String?
    @NSManaged public var bottomText: String?
    @NSManaged public var image: NSObject?

}
