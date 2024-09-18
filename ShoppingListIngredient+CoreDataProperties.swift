//
//  ShoppingListIngredient+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension ShoppingListIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingListIngredient> {
        return NSFetchRequest<ShoppingListIngredient>(entityName: "ShoppingListIngredient")
    }

    @NSManaged public var shopIngredients: String?
    @NSManaged public var shopIsChecked: Bool
    @NSManaged public var shopQuantity: String?
    @NSManaged public var shopRecipe: ShoppingListRecipe?

}

extension ShoppingListIngredient : Identifiable {

}
