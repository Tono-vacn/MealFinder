//
//  communication.swift
//  mealFinder
//
//  Created by Shujie on 11/5/24.
//

import Foundation

func submitPostToBackend(_ postRequest: CreatePostRequest) {
    // 1. set request URL
    guard let url = URL(string: "http://vcm-44239.vm.duke.edu:8080/posts/create") else {
        print("Invalid URL")
        return
    }

    // 2.  CreatePostRequest transform to JSON data
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let jsonData = try? encoder.encode(postRequest) else {
        print("Failed to encode postRequest")
        return
    }

    // 3. set URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer Bfkjg/1wsgiVGpBm62gbMw==", forHTTPHeaderField: "Authorization")
    request.httpBody = jsonData

    // 4. Send request
    URLSession.shared.dataTask(with: request) { data, response, error in
        
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }

       
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                print("Post created successfully!")
            } else {
                print("Failed to create post. Status code: \(httpResponse.statusCode)")
            }
        }

        
        if let data = data {
            let responseString = String(data: data, encoding: .utf8)
            print("Response data: \(responseString ?? "No response data")")
        }
    }.resume()
}

