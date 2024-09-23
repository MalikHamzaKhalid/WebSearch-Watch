//
//  SettingsView.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 05/09/2024.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @ObservedObject var iapManager = IAPManager.shared
    @State var showPurchaseAlert = false

    var body: some View {
        ZStack {
            List {
                // Privacy Policy and Terms Section
                Section(header: Text("Legal")) {
                    Button("Privacy Policy") {
                       openUrl(url: Constants.kPrivacyPolicy)
                    }
                    
                    Button("Terms and Conditions") {
                       openUrl(url: Constants.kTermsConditions)
                    }
                }
                
                Section {
                    Button(action: {
                        showPurchaseAlert = true
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .imageScale(.small)
                            Text("Try Pro")
                                .font(.system(size: 14))
                        }
                    }
                    
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
        .sheet(isPresented: $showPurchaseAlert) {
            InAppPurchaseView()
        }
    }
    
    func openUrl(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: nil
        ) { _, _ in
            
        }
        
        // Makes the "Watch App Wants To Use example.com to Sign In" popup not show up
        session.prefersEphemeralWebBrowserSession = true
        
        session.start()
    }
}


#Preview {
    SettingsView()
}
