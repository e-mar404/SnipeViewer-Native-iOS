//
//  AuthViewModel.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/19/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

enum AuthViewError: Error {
    case tooManyRequests
    case internalError
    case unknown
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            let error = error as NSError
            let errorType = AuthErrorCode.Code(rawValue: error.code)
            
            switch errorType {
                case .tooManyRequests:
                    throw AuthViewError.tooManyRequests
                case .internalError:
                    throw AuthViewError.internalError
                default:
                    throw AuthViewError.unknown
            }
            
        }
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
}
