//
//  PostService.swift
//  mealFinder
//
//  Created by Shujie on 11/6/24.
//


import Foundation

class PostService {
    static let shared = PostService()
    private let baseURL = "http://vcm-44239.vm.duke.edu:8080/posts"
    private let bearerToken = "Bearer gzg8ByILw4zvcJSdJhjzpg=="

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
