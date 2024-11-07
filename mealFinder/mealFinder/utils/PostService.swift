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
    
    //MARK: Llike a post
    func likePost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)/like") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    //MARK: Dislike a post
    func dislikePost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)/dislike") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    //MARK: Fetch a single post
    func fetchPost(by postId: String, completion: @escaping (Result<Post, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                let post = try JSONDecoder().decode(Post.self, from: data)
                completion(.success(post))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: delete a post
    func deletePost(postId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(postId)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                completion(.success(()))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }.resume()
    }
    
    // MARK: fetch all posts
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
