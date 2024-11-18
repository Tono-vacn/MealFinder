//
//  UserService.swift
//  mealFinder
//
//  Created by Shujie on 11/7/24.
//

import Foundation

class UserService {
    static let shared = UserService()

    private let baseURL = "http://vcm-44239.vm.duke.edu:8080/users/me"
    private let bearerToken = "Bearer Bfkjg/1wsgiVGpBm62gbMw=="

    func fetchCurrentUser(completion: @escaping (Result<String, Error>) -> Void) {
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
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(userResponse.id))
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

