//
//  Home.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 12/11/23.
//

import SwiftUI
import GoogleSignIn

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    private var user = GIDSignIn.sharedInstance.currentUser
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(user?.profile?.name ?? "")
                            .font(.headline)
                        
                        Text(user?.profile?.email ?? "")
                            .font(.subheadline)
                    }
                    
                }
                
                Button(action: viewModel.signOutWithGoogle) {
                          Text("Sign out")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemIndigo))
                            .cornerRadius(12)
                            .padding()
                        }

            }
            .navigationTitle("Test")
        }
    }
}

#Preview {
    HomeView()
}
