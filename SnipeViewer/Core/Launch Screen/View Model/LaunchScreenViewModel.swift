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
    @Published private(set) var state: LaunchScreenStep = .firstStep
    
    func dismiss() {
        Task {
            state = .secondStep
            try? await Task.sleep(for: Duration.seconds(1))
            self.state = .finished
        }
    }
}
