//
//  DetailView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct DetailView: View {
    let recipe: Recipe
    let recipeService = RecipeService()
    @State private var instructions: String = "Loading instructions..."
    @State private var errorMessage: String? = nil
    
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
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding(.vertical)
                    
                    ScrollView {
                                    Text(instructions) // Displays instructions or loading message
                                        .padding()
                                }
                }
                .padding()
            }
            

            Spacer()
            

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
            }
        }
        .navigationTitle("Cooking steps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareRecipe) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
                        // Fetch instructions when DetailView appears
            recipeService.getRecipeInstructions(recipeId: recipe.id) {
                                instructions in
                                DispatchQueue.main.async {
                                    self.instructions = instructions
                                }
                            }
                    }
    }
    

    func saveRecipe() {
        print("Recipe saved!")
    }
    
    func shareRecipe() {
        print("Recipe shared!")
    }
}
