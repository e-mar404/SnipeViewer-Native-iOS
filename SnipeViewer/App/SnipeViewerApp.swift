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
    @StateObject var viewModel = AuthViewModel()
    @StateObject var launchScreenState = LaunchScreenViewModel()
    
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
