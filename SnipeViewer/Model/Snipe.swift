//
//  Asset.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import Foundation

struct SnipeData: Codable {
    let API_KEY: String
    let BASE_URL: String
}

struct Asset: Codable{
    let name: String
    let assignedTo: AssignedAsset
}

struct AssignedAsset: Codable {
    let name: String
}

enum SnipeError: Error{
    case invalidSetUp
    case invalidURL
    case invalidResponse
    case invalidData
}

extension Asset {
    static var MOCK_ASSIGNED_ASSET = AssignedAsset(name: "Cart T")
    static var MOCK_ASSET = Asset(name: "T19-1", assignedTo: MOCK_ASSIGNED_ASSET)
}

class Snipe: ObservableObject {
    @Published private var _isLoading:Bool = false
    
    var isLoading: Bool {
        get { return _isLoading }
    }
    
    @MainActor
    public func getAsset(BASE_URL: String, API_KEY: String, assetTag:String) async throws -> Asset{
        _isLoading = true
        
        let endpoint = "\(BASE_URL)hardware/bytag/\(assetTag)"
        
        guard let url = URL(string: endpoint) else {
            throw SnipeError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw SnipeError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            _isLoading = false
            return try decoder.decode(Asset.self, from: data)
        } catch {
            throw SnipeError.invalidData
        }
    }
}
