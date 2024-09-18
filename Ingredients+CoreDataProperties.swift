//
//  Ingredients+CoreDataProperties.swift
//  Meal Preparing
//
//  Created by JoshipTy on 1/9/24.
//
//

import Foundation
import CoreData


extension Ingredients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredients> {
        return NSFetchRequest<Ingredients>(entityName: "Ingredients")
    }

    @NSManaged public var ingredients: String?
    @NSManaged public var isChecked: Bool
    @NSManaged public var quantity: String?
    @NSManaged public var recipe: Recipes?

}

extension Ingredients : Identifiable {

}
