//
//  IngredientData.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/5/24.
//
import SwiftData

@Model
class IngredientData {
    var id: Int
    var name: String
    var amount: Double
    var unit: String
    var original: String
    var image: String
    
    init(id: Int, name: String, amount: Double, unit: String, original: String, image: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.original = original
        self.image = image
    }
}
