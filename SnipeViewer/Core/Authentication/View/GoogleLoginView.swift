//
//  GoogleLoginView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 12/8/23.
//

import SwiftUI
import GoogleSignInSwift

struct GoogleLoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "gear")
            
            Text("signin with google")
                .fontWeight(.black)
                .foregroundColor(Color(.systemIndigo))
                .font(.largeTitle)
                .multilineTextAlignment(.center)
        
            
            GoogleSignInButton(action: viewModel.signInWithGoogle)
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    GoogleLoginView()
        .environmentObject(AuthViewModel())
}
