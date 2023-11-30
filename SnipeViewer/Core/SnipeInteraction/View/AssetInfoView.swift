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
    
    // TO-DO: make an actual alert view
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
    
    var body: some View {
        if let user = viewModel.currentUser {
            // make zstack to have the list view allways on the background
            ZStack{
                List{
                    Section("Asset Info"){
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // if there is no name REST API response is "" which means asset?.name ?? "No name" doesn't work
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
                    
                    if user.admin {
                        Section("Actions (comming soon)"){
                            ActionView(imageName: "gear",
                                       title: "Check in",
                                       tintColor: Color(.systemGray))
                            ActionView(imageName: "gear",
                                       title: "Check out",
                                       tintColor: Color(.systemGray))
                            ActionView(imageName: "gear",
                                       title: "Rename",
                                       tintColor: Color(.systemGray))
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
                
                if snipeVm.isLoading {
                    loadingWheel()
                    
                } else if showErrorAlert || status?.status == "error"{
                    alert
                        .frame(width: 200, height: 180)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10.0)
                    
                }
            }
            .task {
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
