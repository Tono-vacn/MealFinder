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
}

struct Ingredient: Decodable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let original: String
    let image: String
}

class RecipeService {
    private let apiKey = "eb7eed994fc64755be038c4e3f7cc3c6"
    private let baseURL = "https://api.spoonacular.com/recipes/findByIngredients"
    
    func searchRecipes(ingredients: [String], number: Int = 10, ranking: Int = 1, ignorePantry: Bool = true, completion: @escaping (Result<[Recipe], Error>) -> Void) {

        let ingredientsList = ingredients.joined(separator: ",")
        

        let urlString = "\(baseURL)?apiKey=\(apiKey)&ingredients=\(ingredientsList)&number=\(number)&ranking=\(ranking)&ignorePantry=\(ignorePantry)"
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
                completion(.success(recipes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
