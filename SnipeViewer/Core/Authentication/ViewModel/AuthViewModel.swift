//
//  AuthViewModel.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/19/23.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
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

enum SignedInState {
    case signedIn
    case signedOut
}

//@MainActor
class AuthViewModel: ObservableObject {
//    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var state: SignedInState = .signedOut
    
//    init() {
//        self.userSession = Auth.auth().currentUser
//        
//        // need to run when initialized to see if there is already a user session ongoing
//        Task {
//            await fetchUser()
//        }
//    }
    
    func signInWithGoogle() {
        if  GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
            authenticateUser(for: user?.user, with: error)
        }
    }
    
    private func authenticateUser(for user:GIDGoogleUser?, with error: Error?){
        if let error = error {
            print(error)
            return
        }
        
        guard let user = user, let idToken = user.idToken?.tokenString else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { user, error in
            if let error = error {
                print(error)
            } else {
                self.state = .signedIn
            }
        }
    }
    
    func signOutWithGoogle() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
//            self.userSession = result.user
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
//            self.userSession = nil
            self.currentUser = nil // even though this is a local var we need to set to nil just so it doesnt go to cache and cause issues later
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
