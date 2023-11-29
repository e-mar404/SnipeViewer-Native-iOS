//
//  LaunchScreenView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/26/23.
//

import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenViewModel
    
    @State private var firstAnimation = false
    @State private var secondAnimation = false
    @State private var startFadeoutAnimation = false
    
    @ViewBuilder
    private var image: some View {
            Image(systemName: "hurricane")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800))
                .scaleEffect(secondAnimation ? 0 : 1)
                .offset(y: secondAnimation ? 400 : 0)
    }
    
    @ViewBuilder
    private var backgroundColor: some View {
        Color.white.ignoresSafeArea()
    }
    
    private let animationTimer = Timer
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor
            image
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()
        }.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
    private func updateAnimation() {
        switch launchScreenState.state {
            case .firstStep:
                withAnimation(.easeInOut(duration: 0.9)) {
                    firstAnimation.toggle()
                }
            case .secondStep:
                if secondAnimation == false {
                    withAnimation(.linear) {
                        self.secondAnimation = true
                        startFadeoutAnimation = true
                    }
                }
            case .finished:
                break
        }
    }
}

#Preview {
    LaunchScreenView()
        .environmentObject(LaunchScreenViewModel())
}
