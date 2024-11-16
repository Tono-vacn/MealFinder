//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct FindView: View {
    @State private var ingredientsInput: String = ""  // input ingredients
    @State private var recipes: [Recipe] = []         // searched receipe
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil    
    @State private var selectedRecipeIndex: Int? = nil

    let recipeService = RecipeService()

    var body: some View {
        VStack {

            TextField("Enter ingredients (comma separated)", text: $ingredientsInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())


            Button(action: searchRecipes) {
                Text("Search Recipes")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()


            if isLoading {
                ProgressView("Loading recipes...")
            }

 
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .overlay(

            Group {
                if let index = selectedRecipeIndex {
                    RecipePopUpView(
                        recipe: recipes[index],
                        onPrevious: previousRecipe,
                        onNext: nextRecipe,
                        onClose: { selectedRecipeIndex = nil }
                    )
                }
            }
        )
    }


    private func searchRecipes() {
        isLoading = true
        errorMessage = nil
        recipes = []


        let ingredients = ingredientsInput.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

  
        recipeService.searchRecipes(ingredients: ingredients) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                    if !recipes.isEmpty {
                        self.selectedRecipeIndex = 0
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

 
    private func previousRecipe() {
        if let index = selectedRecipeIndex, index > 0 {
            selectedRecipeIndex = index - 1
        }
    }


    private func nextRecipe() {
        if let index = selectedRecipeIndex, index < recipes.count - 1 {
            selectedRecipeIndex = index + 1
        }
    }
}
