//
//  SettingsView.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 05/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var iapManager = IAPManager.shared

    var body: some View {
        ZStack {
            List {
                // Privacy Policy and Terms Section
                Section(header: Text("Legal")) {
                    Link(destination: URL(string: Constants.kPrivacyPolicy)!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .imageScale(.small)  // Decrease icon size
                            Text("Privacy Policy")
                                .font(.system(size: 14))  // Decrease font size
                        }
                    }
                    
                    Link(destination: URL(string: Constants.kTermsConditions)!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .imageScale(.small)  // Decrease icon size
                            Text("Terms and Conditions")
                                .font(.system(size: 14))  // Decrease font size
                        }
                    }
                }
                
                // Restore Purchases Section
                Section {
                    Button(action: {
                        iapManager.restorePurchases()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .imageScale(.small)
                            Text("Restore Purchases")
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            // Overlay the loader in the center of the screen when processing.
            if iapManager.isProcessingPurchase {
                Color.black.opacity(0.4)  // Darken the background
                    .ignoresSafeArea()
                
                ProgressView("Processing...")
                    .scaleEffect(1.5)  // Make the loader larger
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            iapManager.isProcessingPurchase = false
        }
        .navigationTitle("Settings")
        .alert(isPresented: $iapManager.showAlert) {
            Alert(title: Text("Purchase Status"), message: Text(iapManager.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}


#Preview {
    SettingsView()
}
