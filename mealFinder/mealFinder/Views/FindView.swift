//
//  FindView.swift
//  mealFinder
//
//  Created by Shujie on 10/22/24.
//

import SwiftUI

struct FindView: View {
    @State private var ingredientsInput: String = ""  // input ingredients
    @State private var recipes: [Recipe] = []         // searched receipe
    @State private var isLoading: Bool = false
    @State private var isDetecting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var selectedRecipeIndex: Int? = nil
    
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    let recipeService = RecipeService()
    let defaultImage = ["https://img.spoonacular.com/recipes/673463-312x231.jpg","https://img.spoonacular.com/recipes/633548-312x231.jpg","https://img.spoonacular.com/recipes/646317-312x231.jpg"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // TabView section with images
                TabView {
                    ForEach(defaultImage, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.5)
                                .clipped()
                                .cornerRadius(15)
                                .padding(.horizontal)
                        } placeholder: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.5)
                                ProgressView()
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: geometry.size.height * 0.5)
                
                Spacer(minLength: geometry.size.height * 0.05)
                
                // Title and subtitle section
                VStack(spacing: 10) {
                    Text("Discover Delicious Recipes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                    
                    Text("Enter ingredients or take a picture to find the best recipes for your next meal!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: geometry.size.height * 0.03)
                
                // Search bar section
                VStack(alignment: .leading, spacing: 5){
                    HStack {
                        TextField("", text: $ingredientsInput)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showImagePicker = true
                                    }) {
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                    }
                                }
                            )
                        
                        Button(action: searchRecipes) {
                            Text("Search")
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    Text("Please separate multiple ingredients with commas.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    .padding(.leading)}
                .padding(.horizontal)
                
                //Spacer(minLength: geometry.size.height * 0.02)
                
                if isDetecting{
                    ProgressView("Detecting ingredients...")
                } else if isLoading {
                    ProgressView("Loading recipes...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                // Loading indicator or error message
//                if isLoading {
//                    ProgressView("Loading recipes...")
//                } else if let errorMessage = errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding()
//                }
                
                Spacer() // Push content evenly towards the top
            }
            .padding()
            .overlay(
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$selectedImage) { selectedImage in
                    uploadImage(selectedImage)
                }
            }
        }
    }
    private func compressImage(_ image: UIImage, targetSizeKB: Int = 15, maxDimensions: CGSize = CGSize(width: 128, height: 128)) -> Data? {
        let targetFileSize = targetSizeKB * 1024
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        var resizedImage = image
        
        // Step 1: Resize the image if it exceeds maxDimensions
        if image.size.width > maxDimensions.width || image.size.height > maxDimensions.height {
            resizedImage = resizeImage(image, toFit: maxDimensions) ?? image
        }
        
        // Step 2: Compress the resized image until it fits target size or hits maxCompression
        guard var compressedData = resizedImage.jpegData(compressionQuality: compression) else { return nil }
        
        while compressedData.count > targetFileSize && compression > maxCompression {
            compression -= 0.05
            compressedData = resizedImage.jpegData(compressionQuality: compression) ?? compressedData
        }
        
        // Return the compressed data only if it meets the target size
        return compressedData.count <= targetFileSize ? compressedData : nil
    }
    private func resizeImage(_ image: UIImage, toFit maxDimensions: CGSize) -> UIImage? {
        let aspectWidth = maxDimensions.width / image.size.width
        let aspectHeight = maxDimensions.height / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    private func uploadImage(_ image: UIImage) {
        guard UserDefaults.standard.string(forKey: "userToken") != nil else {
            print("User token not found")
            return
        }
        
        guard let compressedData = compressImage(image) else {
            print("Failed to compress image to target size")
            errorMessage = "Image size exceeds 20 KB, compression failed."
            return
        }
        
        AIService.shared.uploadImage(compressedData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let task):
                    print("Uploaded successfully: \(task.url)")
                    self.pollTaskStatus(taskID: task.taskID)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func pollTaskStatus(taskID: UUID) {
        let pollingInterval: TimeInterval = 2.0
        isDetecting = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + pollingInterval) {
            AIService.shared.checkTaskStatus(taskID: taskID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let taskResponse):
                        switch taskResponse.status {
                        case "pending":
                            print("Task still pending, retrying...")
                            self.pollTaskStatus(taskID: taskID)
                        case "completed":
                            print("Task completed: \(taskResponse.result ?? [])")
                            self.handleTaskSuccess(result: taskResponse.result)
                            isDetecting = false
                        case "failed", "error":
                            print("Task failed or encountered an error.")
                            self.errorMessage = "No ingredients detected. Please try another image."
                            isDetecting = false
                        default: break
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func handleTaskSuccess(result: [String]?) {
        isDetecting = false
        if let ingredients = result {
            print("Detected ingredients: \(ingredients.joined(separator: ", "))")
            searchRecipes(ingredients)
        } else {
            print("No result returned.")
        }
    }
    
    private func searchRecipes(_ ingredients: [String]) {
        isLoading = true
        errorMessage = nil
        recipes = []
        recipeService.searchRecipes(ingredients: ingredients){ result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                    if !recipes.isEmpty {
                        self.selectedRecipeIndex = 0
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func searchRecipes() {
        isLoading = true
        errorMessage = nil
        recipes = []
        
        
        let ingredients = ingredientsInput.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        
        recipeService.searchRecipes(ingredients: ingredients) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let recipes):
                    self.recipes = recipes
                    if !recipes.isEmpty {
                        self.selectedRecipeIndex = 0
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    private func previousRecipe() {
        if let index = selectedRecipeIndex, index > 0 {
            selectedRecipeIndex = index - 1
        }
    }
    
    
    private func nextRecipe() {
        if let index = selectedRecipeIndex, index < recipes.count - 1 {
            selectedRecipeIndex = index + 1
        }
    }
}

struct RecipeImageView: View {
    let recipe: Recipe
    
    var body: some View {
        if !recipe.image.isEmpty, let url = URL(string: recipe.image) {
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
        } else {
            Color.gray.opacity(0.3) // Placeholder color if no image is available
        }
    }
}

