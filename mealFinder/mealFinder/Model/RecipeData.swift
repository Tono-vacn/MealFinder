//
//  Recipe.swift
//  mealFinder
//
//  Created by Xueyi Fu on 10/22/24.
//

import Foundation
import SwiftData

@Model
class RecipeData: Identifiable{
    @Attribute(.unique) var id: Int
    var title: String
    var image: String
    var usedIngredientCount: Int
    var missedIngredientCount: Int
    var descriptionText: String?
    var usedIngredients: [IngredientData]
    var missedIngredients: [IngredientData]
    
    init(id: Int, title: String, image: String, usedIngredientCount: Int, missedIngredientCount: Int, descriptionText: String?, usedIngredients: [IngredientData], missedIngredients: [IngredientData]) {
            self.id = id
            self.title = title
            self.image = image
            self.usedIngredientCount = usedIngredientCount
            self.missedIngredientCount = missedIngredientCount
            self.descriptionText = descriptionText
            self.usedIngredients = usedIngredients
            self.missedIngredients = missedIngredients
        }
}
