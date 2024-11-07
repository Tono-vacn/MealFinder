//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI
import SwiftData

struct LibView: View {
    @Query var savedRecipes: [RecipeData]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            List {
                ForEach(savedRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                
                                AsyncImage(url: URL(string: recipe.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                                
                                Text(recipe.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.leading, 10)
                                    .lineLimit(2)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Ingredients:")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                HStack {
                                        let allIngredients = (recipe.usedIngredients + recipe.missedIngredients)
                                            .map { $0.name }
                                            .joined(separator: ", ")
                                        
                                        Text(allIngredients)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                
//                                if !recipe.usedIngredients.isEmpty {
//                                    ForEach(recipe.usedIngredients, id: \.id) { ingredient in
//                                        Text("• \(ingredient.original)")
//                                            .font(.body)
//                                            .foregroundColor(.primary)
//                                    }
//                                }
//
//                                if !recipe.missedIngredients.isEmpty {
//                                    ForEach(recipe.missedIngredients, id: \.id) { ingredient in
//                                        Text("• \(ingredient.original)")
//                                            .font(.body)
//                                            .foregroundColor(.secondary)
//                                    }
//                                }
                            }
                            .padding(.leading, 5)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteRecipe)
            }
            .navigationTitle("Saved Recipes")
        }
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            let recipe = savedRecipes[index]
            modelContext.delete(recipe)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete recipe: \(error)")
        }
    }
}

