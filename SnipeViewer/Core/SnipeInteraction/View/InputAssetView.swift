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
    @State private var isPresentingScanner: Bool = false
    @State private var isPresentingUserProfile: Bool = false
    @State private var lookUpAssetSelection: Bool = false
    @State private var assetTag:String = ""
    @FocusState private var isFocused
    
    // open profile view as a sheet
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
    
    /*
     Note: after the scanner gets the code from a valid barcode it updates the assetTag var but does not submit it to AssetInfoView. The user has to manually click "look up assset".
     */
    // open the scanner as a sheet
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
                    ZStack{
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.blue)
                        Text("Look up asset")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                .opacity(formIsValid ? 1.0 : 0.5)
                .disabled(!formIsValid)
                .padding(.top, 24)
                
                Spacer()
            }
        }
    }
}

// for validation, cant make to only accept 4 digit asset tags because we have some with more than 4 but our min is 4
extension InputAssetView: AssetFormProtocol {
    var formIsValid: Bool {
        return assetTag.count >= 4
    }
}

#Preview {
    InputAssetView()
        .environmentObject(AuthViewModel())
}
