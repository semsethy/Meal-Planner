//
//  Firestores.swift
//  Meal Preparing
//
//  Created by JoshipTy on 16/8/24.
//

import Foundation

struct RecipeData: Codable {
    var recipeID: String?
    var title: String?
    var descrip: String?
    var image: String? // Store image as Base64 string or handle separately
    var selectedDate: String?
    var mealTime: String?
    var remindMe: Bool
    var timeSpent: String?
    var day: String?
    var ingredients: [String] // List of ingredient IDs or names
}
