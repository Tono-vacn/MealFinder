//
//  AIService.swift
//  mealFinder
//
//  Created by Xueyi Fu on 11/18/24.
//

import Foundation
import UIKit

class AIService {
    // Shared instance (optional, for global access)
    static let shared = AIService()
    
    private let baseURL = "http://vcm-44239.vm.duke.edu:8080/tasks"
    
    func compressImage(_ image: UIImage, targetSizeKB: Int = 20) -> Data? {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        let targetSize = targetSizeKB * 1024
        
        guard var compressedData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while compressedData.count > targetSize && compression > maxCompression {
            compression -= 0.1
            compressedData = image.jpegData(compressionQuality: compression) ?? compressedData
        }
        
        return compressedData.count <= targetSize ? compressedData : nil
    }
    
    func uploadImage(_ imageData: Data, completion: @escaping (Result<TaskDTO, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let boundary = UUID().uuidString
        guard let url = URL(string: "\(baseURL)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print(imageData.count)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }
            
            do {
                let taskResponse = try JSONDecoder().decode(TaskDTO.self, from: data)
                completion(.success(taskResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    func checkTaskStatus(taskID: UUID, completion: @escaping (Result<CheckTaskResponse, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/\(taskID)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }
            
            do {
                let taskStatusResponse = try JSONDecoder().decode(CheckTaskResponse.self, from: data)
                completion(.success(taskStatusResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct TaskDTO: Decodable {
    var taskID: UUID
    var key: String
    var url: String
}
struct CheckTaskResponse: Decodable {
    var taskID: UUID
    var status: String
    var result: [String]? // the result of the task
}


