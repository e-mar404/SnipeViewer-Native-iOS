//
//  InputView.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    @FocusState private var isPasswordShowing
    let title: String
    let placeholder: String
    var isSecureField: Bool = false
    
    
    var securedFieldView: some View {
        Group {
            SecureField(placeholder, text: $text)
                .font(.system(size: 14))
                .focused($isPasswordShowing, equals: false)
                .opacity(isPasswordShowing ? 0.0 : 1.0)
                .submitLabel(.done)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .autocorrectionDisabled(true)
                .focused($isPasswordShowing, equals: true)
                .opacity(isPasswordShowing ? 1.0 : 0.0)
                .submitLabel(.done)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                ZStack (alignment: .trailing) {
                    securedFieldView
                    
                    Button{
                        isPasswordShowing = !isPasswordShowing
                    } label: {
                        Image(systemName: !isPasswordShowing ? "eye" : "eye.slash")
                            .imageScale(.small)
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            } else {
                TextField(placeholder, text:$text)
                    .font(.system(size: 14))
                    .submitLabel(.done)
            }
            
            Divider()
            
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "example@betaacademy.com", isSecureField: true)
}
