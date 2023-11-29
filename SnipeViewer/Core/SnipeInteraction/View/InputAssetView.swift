//
//  InputAsset.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI
import CodeScanner

struct InputAssetView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isPresentingScanner = false
    @State private var isPresentingUserProfile = false
    @State private var assetTag:String = ""
    @FocusState private var isFocused
    
    
    var profileSheet: some View {
        ProfileView()
            .environmentObject(viewModel)
    }
    
    var viewProfile: some View{
        Button {
            print("open profile")
            self.isPresentingUserProfile = true
        } label: {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
        }
        
        .frame(width: 40, height: 40)
        .padding(.trailing, 20)
        .sheet(isPresented: $isPresentingUserProfile, content: {
            self.profileSheet
        })
    }
    
    var scannerSheet: some View {
        CodeScannerView(codeTypes: [.code128]) { result in
            if case let .success(code) =  result {
                self.assetTag = code.string
                self.isPresentingScanner = false
            }
        }
    }
    
    var openScanner:some View {
        Button {
            print("scan asset tag")
            self.isPresentingScanner = true
        } label: {
            Image(systemName: "camera")
        }
        .sheet(isPresented: $isPresentingScanner, content: {
            self.scannerSheet
        })
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    viewProfile
                }
                Spacer()
                // manual input of asset tag or button to scan
                HStack(spacing: 24) {
                    InputView(text: $assetTag,
                              title: "Asset Tag",
                              placeholder: "####")
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            
                            Button ("Done") {
                                isFocused = false
                            }
                        }
                    }
                    
                    openScanner
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                
                NavigationLink {
                    AssetInfoView(assetTag: assetTag)
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(viewModel)
                } label: {
                    Text("Look up asset")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                .background(Color(.systemBlue))
                .opacity(formIsValid ? 1.0 : 0.5)
                .disabled(!formIsValid)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
            }
        }
    }
}

extension InputAssetView: AssetFormProtocol {
    var formIsValid: Bool {
        return assetTag.count >= 4
    }
}

#Preview {
    InputAssetView()
        .environmentObject(AuthViewModel())
}
