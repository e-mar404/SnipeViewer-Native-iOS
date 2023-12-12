//
//  ProfileView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/27/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var signOut: some View {
        Button {
            viewModel.signOut()
        } label: {
            ActionView(imageName: "arrow.left", title: "Sign Out", tintColor: .red)
        }
        .cornerRadius(10)
    }
    
    var body: some View {
        // will only show a profile if there is a current signed in user (should be if they get to this view)
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.footnote)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                    }
                }
                
                // role assigned to user
                Section ("General"){
                    Text(user.admin ? "Role: admin" : "Role: non-admin")
                }
                    
                // sign out button
                Section ("Actions") {
                    signOut
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
