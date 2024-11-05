//
//  SharePostView.swift
//  mealFinder
//
//  Created by Shujie on 11/5/24.
//

import SwiftUI

struct SharePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var postTitle: String
    @State private var postContent: String
    @State private var recipeTitle: String
    @State private var recipeContent: String
    @State private var ingredients: String

    let recipe: Recipe
    let onSubmit: (CreatePostRequest) -> Void

    init(recipe: Recipe, onSubmit: @escaping (CreatePostRequest) -> Void) {
        self.recipe = recipe
        self.onSubmit = onSubmit

        _postTitle = State(initialValue: recipe.title)
        _postContent = State(initialValue: "Delicious recipe using \(recipe.title)")
        _recipeTitle = State(initialValue: recipe.title)
        _recipeContent = State(initialValue: "Here are the steps to make \(recipe.title).")
        _ingredients = State(initialValue: recipe.usedIngredients.map { $0.name }.joined(separator: ", "))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Post Title", text: $postTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Post Content", text: $postContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Recipe Title", text: $recipeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Recipe Content", text: $recipeContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Ingredients", text: $ingredients)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    let ingredientsArray = ingredients.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            
                    let recipeRequest = CreateRecipeRequest(title: recipeTitle, content: recipeContent, ingredients: ingredientsArray)
                    let postRequest = CreatePostRequest(title: postTitle, content: postContent, recipe: recipeRequest)

 
                    onSubmit(postRequest)


                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Submit Post")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Create Post")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

