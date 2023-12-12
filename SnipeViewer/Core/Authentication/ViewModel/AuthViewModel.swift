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

enum AuthViewError: Error {
    case tooManyRequests
    case internalError
    case unknown
}

enum SignedInState {
    case signedIn
    case signedOut
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: SignedInState = .signedOut
    
    init() {
        // need to run when initialized to see if there is already a user session ongoing
        Task {
            await fetchUser()
        }
    }
    
    func signIn() {
        // this should be caught when doing fetchUser() when initializing the viewModel but could be useful when determining if this user is signin in for the first time(will need to create user bucket)
//        if  GIDSignIn.sharedInstance.hasPreviousSignIn() {
//            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
//                authenticateUser(for: user, with: error)
//            }
//            return
//        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
    
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] user, error in
            authenticateUser(for: user?.user, with: error)
        }
    }

    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(for user:GIDGoogleUser?, with error: Error?) {
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
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        self.state = .signedIn
    }
}
