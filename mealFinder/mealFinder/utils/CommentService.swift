//
//  CommentService.swift
//  mealFinder
//
//  Created by Shujie on 11/17/24.
//

import Foundation

class CommentService {
    static let shared = CommentService()
    private let baseURL = "http://vcm-44239.vm.duke.edu:8080"
    private let bearerToken = "Bearer Bfkjg/1wsgiVGpBm62gbMw=="
    
    
    //MARK: ADD A COMMENT TO A POST
    func addComment(postId: String, comment: CreateCommentRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        //let bearerToken = UserDefaults.standard.string(forKey: "userToken")
        
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/comments") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization") // Token
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(comment)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    //MARK: GET ALL COMMENTS
    func fetchComments(for postId: String, completion: @escaping (Result<[CommentDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/comments") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            do {
                let comments = try JSONDecoder().decode([CommentDTO].self, from: data)
                completion(.success(comments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // MARK: GET REPLIES FOR A COMMENT
    func fetchReplies(for commentId: String, completion: @escaping (Result<[CommentDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/comments/\(commentId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            do {
                let replies = try JSONDecoder().decode([CommentDTO].self, from: data)
                completion(.success(replies))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Like Comment
    func likeComment(commentId: String, completion: @escaping (Result<CommentDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/comments/\(commentId)/like") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization") // Token
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            do {
                let updatedComment = try JSONDecoder().decode(CommentDTO.self, from: data)
                completion(.success(updatedComment))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    // MARK: - Dislike Comment
    func dislikeComment(commentId: String, completion: @escaping (Result<CommentDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/comments/\(commentId)/dislike") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization") // Token
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            do {
                let updatedComment = try JSONDecoder().decode(CommentDTO.self, from: data)
                completion(.success(updatedComment))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    //MARK: ADD A COMMENT TO A COMMENT
    func addReply(to commentId: String, comment: CreateCommentRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/comments/\(commentId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization") // Token required
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(comment) // Encode the comment request body
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "Invalid response", code: statusCode, userInfo: nil)))
                return
            }
            
            completion(.success(())) // Reply added successfully
        }.resume()
    }
    
    
}
