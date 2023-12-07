//
//  AssetSearch.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/18/23.
//

import SwiftUI

struct AssetInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var snipeVm = Snipe()
    @State private var changeNameTo: String = ""
    @State private var isPresentingChangeNameTo: Bool = false
    @State var status: SnipeError.AssetStatus? //optional so it doesnt require status and asset obj from parent view
    @State var asset: Asset? //optional so it doesnt require status and asset obj from parent view
    @State var assetTag: String = ""
    @State var showErrorAlert:Bool = false
    @State var alertMessage: String = ""
    
    @ViewBuilder
    func loadingWheel() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            .frame(width: 48, height: 48)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding(.top, 24)
    }
    
    var alert: some View {
        VStack {
            Text("An error occured")
                .font(.headline)
                .padding(.bottom, 4)

            if status?.status == "error" {
                Text(status?.messages ?? "")
                    .foregroundColor(.red)
            } else {
                Text("Message: \(alertMessage)")
                    .foregroundColor(.red)
            }
            
            
            Button {
                dismiss()
            } label: {
                Text("Search another asset")
            }
            .padding(.top, 24)
        }
    }
    
    // ui for changing name of asset
    var changeNameSheet: some View {
        VStack {
            InputView(text: $changeNameTo,
                      title: "What would you like name the asset?",
                      placeholder: "new name")
            
            if let user = viewModel.currentUser { // need to have user signed in to get their API key
                Button {
                    Task {
                        let res = try? await snipeVm.changeAssetName(BASE_URL: user.BASE_URL, API_KEY: user.API_KEY, asset: asset!, to: changeNameTo)
                        self.isPresentingChangeNameTo = false
                    }
                } label: {
                    Text("Rename Asset")
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                        .foregroundColor(.white)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    // button to open sheet
    var openChangeName: some View {
        Button {
            self.isPresentingChangeNameTo = true
            print("rename pressed")
        } label: {
            ActionView(imageName: "gear",
                       title: "Rename",
                       tintColor
                       : Color(.systemGray))
        }
        .sheet(isPresented: $isPresentingChangeNameTo, content: {
            self.changeNameSheet
        })
    }
    
    var body: some View {
        if let user = viewModel.currentUser {
            // make zstack to have the list view always on the background
            ZStack{
                List{
                    Section("Asset Info"){
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // if there is no name, name = "" in JSON file which means asset.name is never nil, so we have to check maually to see if asset has a name
                            if asset?.name == "" {
                                Text("No name")
                            } else {
                                Text(asset?.name ?? "")
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("Assigned To")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // for when theres an error (asset is nil) "not assigned to anyone" is on the background but with this it gets rid of it
                            if asset != nil {
                                Text(asset?.assignedTo?.name ?? "Not assigned to anyone")
                            }
                        }
                    }
                    
                    // these actions are only available to admins since they interact with the Snipe IT API
                    if user.admin {
                        Section("Actions (more coming soon)"){
                            openChangeName
                            // depend on allowed actions (found in Asset.availableActions.checkin/checkout)
                            // check in
                            // check out
                        }
                    }
                    
                    Section {
                        Button {
                            print("search another asset")
                            dismiss()
                        } label: {
                            ActionView(imageName: "arrow.left.circle.fill",
                                       title: "Search another asset",
                                       tintColor: .blue)
                        }
                    }
                }
                
                // loading wheel has to be at the end so it can show at the top of the view
                if snipeVm.isLoading {
                    loadingWheel()
                    
                } else if showErrorAlert || status?.status == "error"{
                    alert
                        .frame(width: 200, height: 180)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10.0)
                    
                }
            }
            .task { // .task runs at the creationg of the view
                do {
                    (status, asset) = try await snipeVm.getAsset(BASE_URL: user.BASE_URL, API_KEY: user.API_KEY, assetTag: assetTag)
                } catch SnipeError.codes.invalidURL {
                    alertMessage = "Invalid API URL"
                    showErrorAlert = true
                } catch SnipeError.codes.invalidAuthentication {
                    alertMessage = "Invalid authentication for action"
                    showErrorAlert = true
                    
                } catch SnipeError.codes.notFound{
                    alertMessage = "Requested URL not found"
                    showErrorAlert = true
                    
                } catch SnipeError.codes.invalidResponse {
                    alertMessage = "Got an invalid response from API server"
                    showErrorAlert = true
                    
                } catch SnipeError.codes.invalidData {
                    alertMessage = "Received back invalid data. Possible that asset does not exist"
                    showErrorAlert = true
                    
                } catch {
                    alertMessage = "An unexpected error occured"
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
//    AssetInfoView(asset: .constant(Asset(name: "T19-1", assignedTo: AssignedAsset(name: "Cart - T"))))
    AssetInfoView(
                status: SnipeError.AssetStatus(status: "accepted",
                                               messages: "able to retrieve asset succesfully",
                                               payload: nil),
                assetTag: "4808")
        .environmentObject(AuthViewModel())
}
