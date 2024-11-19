//
//  UserService.swift
//  mealFinder
//
//  Created by Shujie on 11/7/24.
//

import Foundation

class UserService {
    static let shared = UserService()

    private let bearerToken = "Bearer Bfkjg/1wsgiVGpBm62gbMw=="
    private let loginURL = "http://vcm-44239.vm.duke.edu:8080"

    func registerUser(username: String, email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let url = URL(string: "\(loginURL)/users") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "username": username,
                "email": email,
                "password": password
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let user = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(true))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
        
        func loginUser(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
            guard let url = URL(string: "\(loginURL)/users/login") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "username": username,
                "password": password
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(LoginResponse.self, from: data)
                    completion(.success(result.token))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func fetchCurrentUser(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(loginURL)/users/me") else {
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
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(userResponse.id))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUser(by userId: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let url = URL(string: "\(loginURL)/users/\(userId)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.addValue(bearerToken, forHTTPHeaderField: "Authorization")

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
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(userResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct UserResponse: Codable {
    let id: String
    let username: String
    let email: String
}
struct LoginResponse: Codable {
    let token: String
}

