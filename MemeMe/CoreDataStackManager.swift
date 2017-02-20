/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, the managed object model, and a URL for the persistent store.
*/

import UIKit
import CoreData

class CoreDataStackManager {
    // MARK: Properties
    
    static let sharedManager = CoreDataStackManager()
    static let mainStoreFileName = "MemeMe.sqlite"
    static let errorDomain = "CoreDataStackManager"

    /// The managed object model for the application.
    lazy var managedObjectModel: NSManagedObjectModel = {
        /*
            This property is not optional. It is a fatal error for the application 
            not to be able to find and load its model.
        */
        let modelURL = Bundle.main.url(forResource: "MemeMe", withExtension: "momd")!

        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    /// Primary persistent store coordinator for the application.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        /*
            This implementation creates and return a coordinator, having added the 
            store for the application to it. (The directory for the store is created, if necessary.)
        */
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]

            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        }
        catch {
            fatalError("Could not add the persistent store: \(error).")
        }

        return persistentStoreCoordinator
    }()
    
    /// The directory the application uses to store the Core Data store file.
    lazy var documentDirectory: URL = {
        let fileManager = FileManager.default
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls.last!
        return docURL
    }()
    
    /// URL for the main Core Data store file.
    lazy var storeURL: URL = {
        return self.documentDirectory.appendingPathComponent(mainStoreFileName)
    }()
    
    // Creates a new Core Data stack and returns a managed object context associated with a private queue.
    func createPrivateQueueContext() throws -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
        context.performAndWait() {
        
            context.persistentStoreCoordinator = CoreDataStackManager.sharedManager.persistentStoreCoordinator
        
            // Avoid using default merge policy in multi-threading environment:
            // when we delete (and save) a record in one context,
            // and try to save edits on the same record in the other context before merging the changes,
            // an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
            // Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // In OS X, a context provides an undo manager by default
            // Disable it for performance benefit
            context.undoManager = nil
        }
    
        return context
    }
}
