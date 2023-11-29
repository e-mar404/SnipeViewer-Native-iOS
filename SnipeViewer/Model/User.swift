//
//  User.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import Foundation


struct User: Identifiable, Codable {
    let id: String
    var API_KEY: String = ""
    let email: String
    let fullname:String
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    var BASE_URL: String = ""
    var admin: Bool = false
}


extension User {
    static var MOCK_ADMIN_USER = User(id: NSUUID().uuidString, email: "mockadminuser@betaacademy.org", fullname: "Emilio Marin", admin: true)
    static var MOCK_REGULAR_USER = User(id: NSUUID().uuidString, email: "mockregularuser@betaacademy.org", fullname: "Emilio Marin")
}
