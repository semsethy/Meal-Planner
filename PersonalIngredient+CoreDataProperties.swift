//
//  PersonalIngredient+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension PersonalIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalIngredient> {
        return NSFetchRequest<PersonalIngredient>(entityName: "PersonalIngredient")
    }

    @NSManaged public var perIngredient: String?
    @NSManaged public var perIsChecked: Bool
    @NSManaged public var perQuantity: String?
    @NSManaged public var perRecipe: PersonalRecipe?

}

extension PersonalIngredient : Identifiable {

}
