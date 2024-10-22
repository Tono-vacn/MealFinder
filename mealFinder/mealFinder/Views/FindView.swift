//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct FindView: View {
    @State private var ingredientsInput: String = ""  // 用户输入的食材
    @State private var recipes: [Recipe] = []         // 搜索到的菜谱
    @State private var isLoading: Bool = false        // 加载状态
    @State private var errorMessage: String? = nil    // 错误消息
    @State private var selectedRecipeIndex: Int? = nil  // 当前弹出窗口的菜谱索引

    let recipeService = RecipeService()  // 模拟服务类

    var body: some View {
        VStack {
            // 输入框：输入食材
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
        }
        .padding()
        .overlay(
            // 弹出菜谱详情窗口
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

    // 搜索菜谱逻辑
    private func searchRecipes() {
        isLoading = true
        errorMessage = nil
        recipes = []

        // 将输入的食材分割为数组
        let ingredients = ingredientsInput.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        // 调用 API 搜索菜谱
        recipeService.searchRecipes(ingredients: ingredients) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                    if !recipes.isEmpty {
                        self.selectedRecipeIndex = 0  // 弹出第一个菜谱
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // 上一个菜谱
    private func previousRecipe() {
        if let index = selectedRecipeIndex, index > 0 {
            selectedRecipeIndex = index - 1
        }
    }

    // 下一个菜谱
    private func nextRecipe() {
        if let index = selectedRecipeIndex, index < recipes.count - 1 {
            selectedRecipeIndex = index + 1
        }
    }
}
