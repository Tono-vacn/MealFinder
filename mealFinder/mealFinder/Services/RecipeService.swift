//
//  RecipeService.swift
//  mealFinder
//
//  Created by Xueyi Fu on 10/22/24.
//

import Foundation

struct Recipe: Decodable {
    let id: Int
    let title: String
    let image: String
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let usedIngredients: [Ingredient]
    let missedIngredients: [Ingredient]
    var description: String?
}

struct Ingredient: Decodable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let original: String
    let image: String
}

struct Instruction: Decodable{
    let name: String
    let steps: [Step]
}
struct Step: Decodable{
    let number: Int
    let step: String
    let ingredients: [InstructionIngredient]
}
struct InstructionIngredient: Decodable{
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}

class RecipeService {
    private let apiKey = "eb7eed994fc64755be038c4e3f7cc3c6"
    private let baseURL = "https://api.spoonacular.com/recipes/"
    var recipes: [Recipe] = []
    
    func searchRecipes(ingredients: [String], number: Int = 10, ranking: Int = 1, ignorePantry: Bool = true, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        
        let ingredientsList = ingredients.joined(separator: ",")
        
        
        let urlString = "\(baseURL)findByIngredients?apiKey=\(apiKey)&ingredients=\(ingredientsList)&number=\(number)&ranking=\(ranking)&ignorePantry=\(ignorePantry)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                self.recipes = recipes
                completion(.success(recipes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getRecipeInstructions(recipeId: Int, completion: @escaping (String) -> Void) {
        let urlString = "\(baseURL)\(recipeId)/analyzedInstructions?apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            completion("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                        completion("Failed to fetch instructions: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data else {
                        completion("No data received")
                        return
                    }

            do {
                        let instructions = try JSONDecoder().decode([Instruction].self, from: data)
                        let combinedSteps = instructions
                            .flatMap { $0.steps }
                            .map { "\($0.number). \($0.step)" }
                            .joined(separator: "\n")
                        completion(combinedSteps)
                    } catch {
                        completion("Error decoding instructions: \(error.localizedDescription)")
                    }
        }.resume()
    }
}


