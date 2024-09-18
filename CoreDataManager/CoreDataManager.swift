//
//  CoreDataManager.swift
//  Meal Preparing
//
//  Created by JoshipTy on 10/8/24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let container = NSPersistentContainer(name: "Meal_Preparing")
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    private init() {
        //light migrate
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = url.appendingPathComponent("Notes.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        // Merge
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func save() throws {
        do {
            try context.save()
        } catch {
            print(error)
            throw error
        }
    }
}
