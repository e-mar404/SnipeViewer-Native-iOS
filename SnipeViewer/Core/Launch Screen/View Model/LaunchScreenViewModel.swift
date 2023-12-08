//
//  LaunchScreenStateManager.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/26/23.
//

import Foundation

enum LaunchScreenStep {
    case firstStep
    case secondStep
    case finished
}

@MainActor
class LaunchScreenViewModel: ObservableObject {
    // needs to be publised but private so it can be read but not updated outside the view model
    @Published private(set) var state: LaunchScreenStep = .firstStep
    
    func dismiss() {
        Task {
            state = .secondStep
            try? await Task.sleep(for: Duration.seconds(1)) // at some point instead of a delay use the time that it takes firebase to connect to the api through the sdk
            self.state = .finished
        }
    }
}
