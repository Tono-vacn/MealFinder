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
    
    let recipe: Recipe
    let onSubmit: (CreatePostRequest) -> Void

    init(recipe: Recipe, onSubmit: @escaping (CreatePostRequest) -> Void) {
        self.recipe = recipe
        self.onSubmit = onSubmit

        _postTitle = State(initialValue: "")
        _postContent = State(initialValue: "")
    }

    var body: some View {
        NavigationView {
            VStack() {
                Spacer()
                // Post Title (Editable)
                TextField("Post Title", text: $postTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Post Content (Editable)
                TextEditor(text: $postContent)
                    .frame(height: 300)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5))
                    )
//                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()

                // Recipe Title (Read-only)
                VStack(alignment: .leading) {
                    Text("Relevant Recipe:")
                        .font(.headline)
                    Text(recipe.title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

//                // Recipe Content (Read-only)
//                VStack(alignment: .leading) {
//                    Text("Recipe Content:")
//                        .font(.headline)
//                    Text(recipe.description ?? "No content available")
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                }
//                .padding(.horizontal)
//
//                // Ingredients (Read-only)
//                VStack(alignment: .leading) {
//                    Text("Ingredients:")
//                        .font(.headline)
//                    Text(recipe.usedIngredients.map { $0.name }.joined(separator: ", "))
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                }
                .padding(.horizontal)
                Spacer()
                // Submit Button
                Button(action: {
                    let ingredientsArray = recipe.usedIngredients.map { $0.name }

                    let recipeRequest = CreateRecipeRequest(title: recipe.title, content: recipe.description ?? "", ingredients: ingredientsArray)
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
