//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import Foundation
import SwiftUI
import SwiftData

struct LibView: View {
    @Query var savedRecipes: [RecipeData]
    
    var body: some View {
        NavigationView {
            List(savedRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        Text("Used Ingredients: \(recipe.usedIngredientCount)")
                            .font(.subheadline)
                        Text("Missed Ingredients: \(recipe.missedIngredientCount)")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Saved Recipes")
        }
    }
    
}

