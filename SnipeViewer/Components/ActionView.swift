//
//  AssetAction.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI

struct ActionView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ActionView(imageName: "gear", title: "Check in/out", tintColor: Color(.systemGray))
}
