//
//  LoginView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Logos (both snipe and beta)
                HStack {
                    // beta image
                    Image("betaacademy-logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 32)
                    
                    // snipe image
                    Image("snipeit-logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 32)
                }
                
                
                // sign in with google implementation
                GoogleSignInButton() {
                    Task{
                        viewModel.signIn()
                        await viewModel.fetchUser()
                    }
                }
                    .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
