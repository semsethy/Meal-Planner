//
//  FavoriteIngredient+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension FavoriteIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteIngredient> {
        return NSFetchRequest<FavoriteIngredient>(entityName: "FavoriteIngredient")
    }

    @NSManaged public var favIngredients: String?
    @NSManaged public var favIsChecked: Bool
    @NSManaged public var favQuantity: String?
    @NSManaged public var favoRecipe: FavoriteRecipe?

}

extension FavoriteIngredient : Identifiable {

}
