//
//  RecipeDetailView.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/5/24.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeData
    let recipeService = RecipeService()
    @State private var errorMessage: String? = nil
    let defaultInstructions: String = "No instructions available."
    @State private var showSharePostView = false
    
    @Environment(\.modelContext) private var modelContext
    
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
                        Text(recipe.descriptionText ?? defaultInstructions) // Displays instructions or loading message
                            .padding()
                    }
                }
                .padding()
            }
            
            
            Spacer()
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
        .sheet(isPresented: $showSharePostView) {
            
        }
    }
    
    func shareRecipe() {
        showSharePostView = true
    }
}
