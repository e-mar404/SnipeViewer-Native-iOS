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
    @State var asset: Asset?
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
            Text("this is an alert view")
            Text("Message: \(alertMessage)")
        }
    }
    
    var body: some View {
        if let user = viewModel.currentUser {
            VStack{
                if snipeVm.isLoading {
                    loadingWheel()
                    
                } else if showErrorAlert {
                    alert
                    
                } else {
                    List{
                        Section("Asset Info"){
                            VStack(alignment: .leading) {
                                Text("Name")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(asset?.name ?? "")
                            }
                            VStack(alignment: .leading) {
                                Text("Assigned To")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(asset?.assignedTo.name ?? "")
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
                }
            }
            .task {
                do {
                    asset = try await snipeVm.getAsset(BASE_URL: user.BASE_URL, API_KEY: user.API_KEY, assetTag: assetTag)
                } catch SnipeError.invalidURL {
                    alertMessage = "Invalid API URL"
                    showErrorAlert = true
                    
                } catch SnipeError.invalidResponse {
                    alertMessage = "Got an invalid response from API server"
                    showErrorAlert = true
                    
                } catch SnipeError.invalidData {
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
    AssetInfoView(assetTag: "4808")
        .environmentObject(AuthViewModel())
}
