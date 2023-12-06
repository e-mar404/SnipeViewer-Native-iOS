//
//  LoginView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI

struct LoginView: View {
    @State private var email:String = ""
    @State private var password: String = ""
    @State private var showErrorAlert = false
    @State private var errorDetails = ""
    @State private var loginAlert:Bool = true
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
                
                
                // form field
                VStack(spacing: 24) {
                    InputView(text: $email, 
                              title: "Email Address",
                              placeholder: "example@betaacademy.org")
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // sign in button
                Button {
                    Task{
                        do {
                            try await viewModel.signIn(withEmail: email, password: password)
                        } catch AuthViewError.internalError{ // when email or password is wrong the overall error is an .internalError (but the message says "invalid_credentials") cant seem to get to the message of the error thrown by firebase so will just generalize .internalError to this
                            errorDetails = "Internal Error. Double check email & password"
                            showErrorAlert = true
                            print("Internal error while signing in")
                        } catch AuthViewError.tooManyRequests{
                            errorDetails = "Too Many Requests"
                            showErrorAlert = true
                            print("Too many request processed")
                        } catch AuthViewError.unknown{
                            errorDetails = "Unkown Error"
                            showErrorAlert = true
                            print("Unkown error")
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign In")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .alert(errorDetails, isPresented: $showErrorAlert) {
                    Button ("OK"){
                        showErrorAlert = false
                    }
                } message: {
                    Text("Please Try Again :)")
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                Spacer()
                
            }
        }
    }
}

// will use to make sure to only accept emails for the email field and that the password is > 7 (which is already a requirement for firebase) this is just to give user the best chance to sign in
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@") // rule to only allow users from "@ourdomain.org" in firebase everyone else cant read or write (no one can write)
        && !password.isEmpty
        && password.count > 7
    }
}
#Preview {
    LoginView()
}
