//
//  Recipes+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension Recipes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipes> {
        return NSFetchRequest<Recipes>(entityName: "Recipes")
    }

    @NSManaged public var day: String?
    @NSManaged public var descrip: String?
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var mealTime: Date?
    @NSManaged public var recipeID: String?
    @NSManaged public var remindMe: Bool
    @NSManaged public var selectedDate: Date?
    @NSManaged public var timeSpent: String?
    @NSManaged public var title: String?
    @NSManaged public var ingredients: NSSet?

}

// MARK: Generated accessors for ingredients
extension Recipes {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredients)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredients)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Recipes : Identifiable {

}
