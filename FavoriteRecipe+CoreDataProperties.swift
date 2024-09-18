//
//  FavoriteRecipe+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension FavoriteRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteRecipe> {
        return NSFetchRequest<FavoriteRecipe>(entityName: "FavoriteRecipe")
    }

    @NSManaged public var favDescrip: String?
    @NSManaged public var favImage: Data?
    @NSManaged public var favImageURL: String?
    @NSManaged public var favRecipeID: String?
    @NSManaged public var favTimeSpent: String?
    @NSManaged public var favTitle: String?
    @NSManaged public var favoIngredient: NSSet?

}

// MARK: Generated accessors for favoIngredient
extension FavoriteRecipe {

    @objc(addFavoIngredientObject:)
    @NSManaged public func addToFavoIngredient(_ value: FavoriteIngredient)

    @objc(removeFavoIngredientObject:)
    @NSManaged public func removeFromFavoIngredient(_ value: FavoriteIngredient)

    @objc(addFavoIngredient:)
    @NSManaged public func addToFavoIngredient(_ values: NSSet)

    @objc(removeFavoIngredient:)
    @NSManaged public func removeFromFavoIngredient(_ values: NSSet)

}

extension FavoriteRecipe : Identifiable {

}
