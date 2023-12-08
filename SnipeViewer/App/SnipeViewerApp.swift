//
//  SnipeViewerApp.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/17/23.
//

import SwiftUI
import Firebase

@main
struct SnipeViewerApp: App {
    @StateObject var viewModel = AuthViewModel() // view models for current user session
    @StateObject var launchScreenState = LaunchScreenViewModel() // view model for launch screen
        
    // need to start the firebase sdk when launching the app
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                    .environmentObject(viewModel)
                
                if launchScreenState.state != .finished {
                    LaunchScreenView()
                }
            }.environmentObject(launchScreenState)
        }
    }
}
