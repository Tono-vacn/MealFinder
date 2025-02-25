//
//  DetailView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let recipe: Recipe
    let recipeService = RecipeService()
    @State private var instructions: String = "Loading instructions..."
    @State private var errorMessage: String? = nil
    let defaultInstructions: String = "No instructions available."
    @State private var showSharePostView = false
    @State private var isRecipeSaved = false
    
    @Environment(\.modelContext) private var modelContext
    @Query var savedRecipes: [RecipeData]

        
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(recipe.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    
                    AsyncImage(url: URL(string: recipe.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.vertical)
                    
                    ScrollView {
                        Text(recipe.description ?? defaultInstructions) // Displays instructions or loading message
                            .padding()
                    }
                }
                .padding()
            }
            
            
            Spacer()
            
            if isRecipeAlreadySaved(){
                Text("Recipe already saved")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .padding(.bottom)
            } else {
                Button(action: saveRecipe) {
                    HStack {
                        Image(systemName: "bookmark.fill")
                        Text("Save")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom)
                }}
        }
        .navigationTitle("Cooking steps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareRecipe) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showSharePostView) {
            SharePostView(recipe: recipe) { postRequest in
                PostService.shared.submitPostToBackend(postRequest)
            }
        }
        //        .onAppear {
        //                        // Fetch instructions when DetailView appears
        //            recipeService.getRecipeInstructions(recipeId: recipe.id) {
        //                                instructions in
        //                                DispatchQueue.main.async {
        //                                    self.instructions = instructions
        //                                }
        //                            }
        //                    }
    }
    
    func isRecipeAlreadySaved()-> Bool {
        return savedRecipes.contains(where: { $0.id == recipe.id })
    }
    func saveRecipe() {
        let usedIngredientData = recipe.usedIngredients.map { ingredient in
            IngredientData(
                id: ingredient.id,
                name: ingredient.name,
                amount: ingredient.amount,
                unit: ingredient.unit,
                original: ingredient.original,
                image: ingredient.image
            )
        }
        
        let missedIngredientData = recipe.missedIngredients.map { ingredient in
            IngredientData(
                id: ingredient.id,
                name: ingredient.name,
                amount: ingredient.amount,
                unit: ingredient.unit,
                original: ingredient.original,
                image: ingredient.image
            )
        }
        
        let recipeData = RecipeData(
            id: recipe.id,
            title: recipe.title,
            image: recipe.image,
            usedIngredientCount: recipe.usedIngredientCount,
            missedIngredientCount: recipe.missedIngredientCount,
            descriptionText: recipe.description,
            usedIngredients: usedIngredientData,
            missedIngredients: missedIngredientData
        )
        
        modelContext.insert(recipeData)
        
        do {
            try modelContext.save()
            print("Recipe saved successfully!")
        } catch {
            print("Failed to save recipe: \(error)")
        }
    }
    
    func shareRecipe() {
        showSharePostView = true
    }
}
