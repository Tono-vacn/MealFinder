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
    
    init(from recipeData: RecipeData) {
            self.id = recipeData.id
            self.title = recipeData.title
            self.image = recipeData.image
            self.usedIngredientCount = recipeData.usedIngredientCount
            self.missedIngredientCount = recipeData.missedIngredientCount
            self.usedIngredients = recipeData.usedIngredients.map { Ingredient(from: $0) }
            self.missedIngredients = recipeData.missedIngredients.map { Ingredient(from: $0) }
            self.description = recipeData.descriptionText
        }
}

struct Ingredient: Decodable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let original: String
    let image: String
    
    init(from ingredientData: IngredientData) {
            self.id = ingredientData.id
            self.name = ingredientData.name
            self.amount = ingredientData.amount
            self.unit = ingredientData.unit
            self.original = ingredientData.original
            self.image = ingredientData.image
        }
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

//class RecipeService {
//    private let apiKey = "eb7eed994fc64755be038c4e3f7cc3c6"
//    private let baseURL = "https://api.spoonacular.com/recipes/"
//    var recipes: [Recipe] = []
//    
//    func searchRecipes(ingredients: [String], number: Int = 10, ranking: Int = 1, ignorePantry: Bool = true, completion: @escaping (Result<[Recipe], Error>) -> Void) {
//        
//        let ingredientsList = ingredients.joined(separator: ",")
//        
//        
//        let urlString = "\(baseURL)findByIngredients?apiKey=\(apiKey)&ingredients=\(ingredientsList)&number=\(number)&ranking=\(ranking)&ignorePantry=\(ignorePantry)"
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
//                return
//            }
//            
//            do {
//                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
//                self.recipes = recipes
//                completion(.success(recipes))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//    
//    func getRecipeInstructions(recipeId: Int, completion: @escaping (String) -> Void) {
//        let urlString = "\(baseURL)\(recipeId)/analyzedInstructions?apiKey=\(apiKey)"
//        guard let url = URL(string: urlString) else {
////            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            completion("Invalid URL")
//            return
//        }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                        completion("Failed to fetch instructions: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    guard let data = data else {
//                        completion("No data received")
//                        return
//                    }
//
//            do {
//                        let instructions = try JSONDecoder().decode([Instruction].self, from: data)
//                        let combinedSteps = instructions
//                            .flatMap { $0.steps }
//                            .map { "\($0.number). \($0.step)" }
//                            .joined(separator: "\n")
//                        completion(combinedSteps)
//                    } catch {
//                        completion("Error decoding instructions: \(error.localizedDescription)")
//                    }
//        }.resume()
//    }
//}
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
                var recipes = try JSONDecoder().decode([Recipe].self, from: data)
                let dispatchGroup = DispatchGroup()
                
                // For each recipe, fetch instructions
                for i in 0..<recipes.count {
                    dispatchGroup.enter()
                    
                    self.getRecipeInstructions(recipeId: recipes[i].id) { instructions in
                        DispatchQueue.main.async {
                            if instructions.isEmpty {
                                recipes[i].description = ""
                            } else {
                                recipes[i].description = instructions
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                // Wait for all instructions fetch to complete
                dispatchGroup.notify(queue: .main) {
                    // Filter out recipes with empty instructions
                    let filteredRecipes = recipes.filter { $0.description != nil && !$0.description!.isEmpty }
                    self.recipes = filteredRecipes
                    completion(.success(filteredRecipes))
                }
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fetches instructions for a specific recipe
    func getRecipeInstructions(recipeId: Int, completion: @escaping (String) -> Void) {
        let urlString = "\(baseURL)\(recipeId)/analyzedInstructions?apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion("")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch instructions for recipe \(recipeId): \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let data = data else {
                print("No data received for recipe \(recipeId)")
                completion("")
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
                print("Error decoding instructions for recipe \(recipeId): \(error.localizedDescription)")
                completion("")
            }
        }.resume()
    }
}



