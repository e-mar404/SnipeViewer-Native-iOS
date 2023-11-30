//
//  Asset.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import Foundation

/*
 Note:
 
 all of the properties under Asset that are in camelCase are in snake_case on the JSON response. Make sure to use JSONDecoder() .convertFromSnakeCase
 */
struct SnipeData: Codable {
    let API_KEY: String
    let BASE_URL: String
}

struct Asset: Codable{
    // definitions of objects under Asset
    struct StatusLabel: Codable {
        let id: Int
        let name: String
        let statusType: String
        let statusMeta: String
    }
    
    struct AssignedTo: Codable {
        let name: String
        let type: String
    }
    
    struct AvailabeActions: Codable {
        let checkout: Bool
        let checkin: Bool
        let clone: Bool
        let restore: Bool
        let update: Bool
        let delete: Bool
    }
    
    // properties of Asset
    let name: String
    let assetTag: String
    let statusLabel: StatusLabel
    let assignedTo: AssignedTo? // make optional, when asset is not checked out this property is null
    let AvailableActions: AvailabeActions
}



enum SnipeError: Error{
    case invalidSetUp
    case invalidURL
    case invalidResponse
    case invalidData
}

class Snipe: ObservableObject {
    @Published private var _isLoading:Bool = false
    
    var isLoading: Bool {
        get { return _isLoading }
    }
    
    // get asset by asset tag and return Asset object
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
    
    // change name of asset
    // POST
    /*
     params:
        - BASE_URL: String
        - API_KEY: String
        - asset: Asset -or- assetTag: String (not sure which works better but if name is going to be changed then user already reached AssetInfoView which means an asset has been returned by getAsset so it is possible to pass an asset object which func can update the name in the local version of the asset and make a POST request to push the changes saving an API call to get the updated version of the asset for when asset)
        - changeNameTo: String (new name to change asset to)
     return:
        - result: Bool (is operation was succesful)
     */
    
    //--------------------------------------------------------------------------------
    
    // check in/out
    // POST
    /*
     params:
        - BASE_URL: String
        - API_KEY: String
        - asset: Asset (will use asset object to see if check in/out is possible)
     ------- (optional)
        - status: Int (new status to set asset to)
     return:
        - res (if operation was successful)
     */
}
