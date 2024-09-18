//
//  ShoppingListRecipe+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension ShoppingListRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingListRecipe> {
        return NSFetchRequest<ShoppingListRecipe>(entityName: "ShoppingListRecipe")
    }

    @NSManaged public var shopDescrip: String?
    @NSManaged public var shopImage: Data?
    @NSManaged public var shopRecipeID: String?
    @NSManaged public var shopTimeSpent: String?
    @NSManaged public var shopTitle: String?
    @NSManaged public var shopIngredient: NSSet?

}

// MARK: Generated accessors for shopIngredient
extension ShoppingListRecipe {

    @objc(addShopIngredientObject:)
    @NSManaged public func addToShopIngredient(_ value: ShoppingListIngredient)

    @objc(removeShopIngredientObject:)
    @NSManaged public func removeFromShopIngredient(_ value: ShoppingListIngredient)

    @objc(addShopIngredient:)
    @NSManaged public func addToShopIngredient(_ values: NSSet)

    @objc(removeShopIngredient:)
    @NSManaged public func removeFromShopIngredient(_ values: NSSet)

}

extension ShoppingListRecipe : Identifiable {

}
