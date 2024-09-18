//
//  PersonalRecipe+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension PersonalRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalRecipe> {
        return NSFetchRequest<PersonalRecipe>(entityName: "PersonalRecipe")
    }

    @NSManaged public var perDescrip: String?
    @NSManaged public var perImage: Data?
    @NSManaged public var perImageURL: String?
    @NSManaged public var perRecipeID: String?
    @NSManaged public var perTimeSpent: String?
    @NSManaged public var perTitle: String?
    @NSManaged public var perIngredient: NSSet?

}

// MARK: Generated accessors for perIngredient
extension PersonalRecipe {

    @objc(addPerIngredientObject:)
    @NSManaged public func addToPerIngredient(_ value: PersonalIngredient)

    @objc(removePerIngredientObject:)
    @NSManaged public func removeFromPerIngredient(_ value: PersonalIngredient)

    @objc(addPerIngredient:)
    @NSManaged public func addToPerIngredient(_ values: NSSet)

    @objc(removePerIngredient:)
    @NSManaged public func removeFromPerIngredient(_ values: NSSet)

}

extension PersonalRecipe : Identifiable {

}
