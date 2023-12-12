//
//  Asset.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import Foundation

/*
 Note:
 
 all of the properties under Asset that are in camelCase are in snake_case on the JSON response. Make sure to use JSONDecoder().convertFromSnakeCase
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
    let id: Int
    var name: String
    let assetTag: String
    let statusLabel: StatusLabel
    let assignedTo: AssignedTo? // make optional, when asset is not checked out this property is null
    let availableActions: AvailabeActions
}

struct SnipeError {
    
    enum codes: Error{
        case invalidURL
        case invalidAuthentication
        case invalidResponse
        case invalidId
        case invalidData
        case notFound
    }
    
    // when trying to get asset that doesnt exist the response is
    /*
     {
        "status": "error",
        "messages": "Asset does not exist",
        "payload": null
     }
     */
    
    struct AssetStatus: Codable{
        let status: String
        let messages: String
        let payload: String?
    }
}

class Snipe: ObservableObject {
    @Published private var _isLoading:Bool = false
    
    var isLoading: Bool {
        get { return _isLoading }
    }
    
    // get asset by asset tag and return Asset object
    @MainActor
    public func getAsset(BASE_URL: String, API_KEY: String, assetTag:String) async throws -> (status: SnipeError.AssetStatus?, asset: Asset?){
        _isLoading = true
        
        let endpoint = "\(BASE_URL)hardware/bytag/\(assetTag)"
        
        guard let url = URL(string: endpoint) else {
            throw SnipeError.codes.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // nesting 404, 401, 200
    
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let response = response as? HTTPURLResponse
            switch response?.statusCode {
                case 401:
                    throw SnipeError.codes.invalidAuthentication
                case 404:
                    throw SnipeError.codes.notFound
                default:
                    throw SnipeError.codes.invalidResponse
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            _isLoading = false
            let asset = try decoder.decode(Asset.self, from: data)
            return (SnipeError.AssetStatus(status: "success", messages: "Able to retrieve asset successfully", payload: nil), asset)
            
        } catch {
            _isLoading = false
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let status = try decoder.decode(SnipeError.AssetStatus.self, from: data)
                return (status, nil)
                
            } catch {
                throw SnipeError.codes.invalidData
            }
        }
    }
    
    // change name of asset
    // PATCH (parially update a specific asset)
    /*
     params:
        - BASE_URL: String
        - API_KEY: String
        - asset: Asset -or- assetTag: String (not sure which works better but if name is going to be changed then user already reached AssetInfoView which means an asset has been returned by getAsset so it is possible to pass an asset object which func can update the name in the local version of the asset and make a POST request to push the changes saving an API call to get the updated version of the asset for when asset)
        - changeNameTo: String (new name to change asset to)
     return:
        - result: Bool (is operation was succesful)
     */
    @MainActor
    public func changeAssetName(BASE_URL: String, API_KEY: String, asset: Asset, to: String) async throws -> Bool{
        _isLoading = true
        
        let endpoint = "\(BASE_URL)hardware/\(asset.id)"
        
        guard let url = URL(string: endpoint) else {
            throw SnipeError.codes.invalidURL
        }
        
        // set up json to send
        var updatedAsset = asset
        updatedAsset.name = to
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try? encoder.encode(updatedAsset)
        
        // request with headers
        var request = URLRequest(url: url)
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "PATCH"
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw SnipeError.codes.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            _isLoading = false
            let status = try decoder.decode(SnipeError.AssetStatus.self, from: data)
            return status.status == "success"
        } catch {
            throw SnipeError.codes.invalidData
        }
    }
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
