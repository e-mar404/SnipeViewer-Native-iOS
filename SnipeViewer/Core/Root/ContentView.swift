//
//  ContentView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/17/23.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject private var launchScreenState: LaunchScreenViewModel
    @State var text = ""
    @FocusState var isFocused
    
    var body: some View {
        Group {
            // only show log in page if there is no saved current user session
//            if viewModel.userSession != nil {
//                InputAssetView()
//            } else {
//                LoginView()
//            }
            switch viewModel.state {
                case .signedIn: HomeView()
                case .signedOut: GoogleLoginView()
            }
        }
        .task{
            // task to launch screen saver and dismiss it
            try? await Task.sleep(for: Duration.seconds(1))
            self.launchScreenState.dismiss()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LaunchScreenViewModel())
        .environmentObject(AuthViewModel())
    
}
