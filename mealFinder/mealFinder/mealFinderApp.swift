//
//  mealFinderApp.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI
import SwiftData

@main
struct mealFinderApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [RecipeData.self, IngredientData.self])
        }
//        .modelContainer(sharedModelContainer)
    }
}
