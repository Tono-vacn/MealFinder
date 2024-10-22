//
//  ContentView.swift
//  mealFinder
//
//  Created by 杨舒捷 on 10/22/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var ingredientsInput: String = ""  // 用户输入的食材
        @State private var recipes: [Recipe] = []         // 搜索到的菜谱
        @State private var isLoading: Bool = false        // 加载状态
        @State private var errorMessage: String? = nil    // 错误消息
        let recipeService = RecipeService()

    var body: some View {
            NavigationView {
                VStack {
                    // 输入框：用于输入食材
                    TextField("Enter ingredients (comma separated)", text: $ingredientsInput)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    // 搜索按钮
                    Button(action: searchRecipes) {
                        Text("Search Recipes")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // 加载状态
                    if isLoading {
                        ProgressView("Loading recipes...")
                    }

                    // 错误信息
                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }

                    // 搜索到的菜谱列表
                    List(recipes, id: \.id) { recipe in
                        VStack(alignment: .leading) {
                            Text(recipe.title)
                                .font(.headline)

                            // 显示菜谱图片
                            AsyncImage(url: URL(string: recipe.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(height: 100)
                        }
                    }
                }
                .navigationTitle("Recipe Search")
            }
            .padding()
        }

        // 调用 RecipeService 进行菜谱搜索
        private func searchRecipes() {
            isLoading = true
            errorMessage = nil
            recipes = []
            
            // 将用户输入的食材分割为数组
            let ingredients = ingredientsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            // 调用 RecipeService 进行 API 搜索
            recipeService.searchRecipes(ingredients: ingredients) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let recipes):
                        self.recipes = recipes
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
