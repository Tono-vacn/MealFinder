//
//  RecipePopUpView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct RecipePopUpView: View {
    let recipe: Recipe
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            
            Text(recipe.title)
                .font(.title)
                .padding()
            
            
            AsyncImage(url: URL(string: recipe.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .padding()
            
            Spacer()

            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !recipe.usedIngredients.isEmpty {
                        Text("Used Ingredients:")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                        
                        ForEach(recipe.usedIngredients, id: \.id) { ingredient in
                            Text("• \(ingredient.original)")
                                .font(.body)
                        }
                    }
                    
                    if !recipe.missedIngredients.isEmpty {
                        Text("Missed Ingredients:")
                            .font(.subheadline)
                            .padding(.top, 10)
                        
                        ForEach(recipe.missedIngredients, id: \.id) { ingredient in
                            Text("• \(ingredient.original)")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 300)
            
            GeometryReader { geometry in
                HStack {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0))
                                    .frame(width: 30, height: 30)
                            )
                    }.padding(10)
                    
                    Spacer()
                    
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0))
                                    .frame(width: 30, height: 30)
                            )
                    }.padding(10)
                    
                }
                .frame(height: 80)
            }
            .frame(height: 100)
        }
        .frame(width: 370, height: 700)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
}
