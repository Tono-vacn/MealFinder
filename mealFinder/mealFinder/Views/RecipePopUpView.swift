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
        
        
        NavigationView{
            NavigationLink(destination: DetailView(recipe: recipe)){
                VStack {
                    
                    HStack {
                        Spacer()
                        Button(action:onClose) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.6)))
                        }
                        
                        .padding(.top)
                        .padding(.trailing)
                    }
                    
                    
                    Text(recipe.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    
                    AsyncImage(url: URL(string: recipe.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 200)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                    } placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 300, height: 200)
                            ProgressView()
                        }
                    }
                    //                    .frame(height: 200)
                    //                    .cornerRadius(10)
                    //                    .padding(.vertical)
                    
                    Spacer()
                    
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            if !recipe.usedIngredients.isEmpty {
                                VStack(alignment: .leading, spacing: 10){
                                    Divider()
                                        .background(Color.gray.opacity(0.5))
                                    Text("Used Ingredients:")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    //.padding(.bottom, 5)
                                    
                                    ForEach(recipe.usedIngredients, id: \.id) { ingredient in
                                        Text("• \(ingredient.original)")
                                            .font(.body)
                                            .foregroundColor(.black)
                                    }}
                            }
                            
                            if !recipe.missedIngredients.isEmpty {
                                VStack(alignment: .leading, spacing: 10){
                                    Divider()
                                        .background(Color.gray.opacity(0.5))
                                    Text("Missed Ingredients:")
                                        .font(.headline)
                                    //.padding(.top, 10)
                                        .foregroundColor(.black)
                                    
                                    ForEach(recipe.missedIngredients, id: \.id) { ingredient in
                                        Text("• \(ingredient.original)")
                                            .font(.body)
                                            .foregroundColor(.black)
                                    }}
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: 350)
                    .padding(.top)
                    
                    HStack {
                        Button(action: onPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.gray.opacity(0.3)))
                                .shadow(radius: 5)
                        }
                        .padding(20)
                        
                        Spacer()
                        
                        Button(action: onNext) {
                            Image(systemName: "chevron.right")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.gray.opacity(0.3)))
                                .shadow(radius: 5)
                        }
                        .padding(20)
                    }
                    .frame(height: 100)
                }}
        }.frame(width: 370, height: 700)
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

#Preview {
    let sampleRecipe = Recipe(from: RecipeData(
        id: 1,
        title: "Delicious Pancakes",
        image: "https://via.placeholder.com/150",
        usedIngredientCount: 2,
        missedIngredientCount: 2,
        descriptionText: "a short description",
        usedIngredients: [
            IngredientData(id: 1, name: "Flour", amount: 2.0, unit: "cups", original: "2 cups of flour", image: ""),
            IngredientData(id: 2, name: "Eggs", amount: 3.0, unit: "pcs", original: "3 eggs", image: "")
        ],
        missedIngredients: [
            IngredientData(id: 3, name: "Milk", amount: 1.0, unit: "cup", original: "1 cup of milk", image: ""),
            IngredientData(id: 4, name: "Butter", amount: 2.0, unit: "tbsp", original: "2 tbsp of butter", image: "")
        ]
    ))
    
    RecipePopUpView(
        recipe: sampleRecipe,
        onPrevious: {
            print("Previous recipe tapped")
        },
        onNext: {
            print("Next recipe tapped")
        },
        onClose: {
            print("Close button tapped")
        }
    )
    .padding()
}

