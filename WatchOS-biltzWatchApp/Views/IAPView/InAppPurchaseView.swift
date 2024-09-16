//
//  InAppPurchaseView.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 02/09/2024.
//

import SwiftUI

struct InAppPurchaseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var iapManager = IAPManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        
                        PurchaseButton(title: "120 Credits for $1.99", isProcessing: $iapManager.isProcessingPurchase) {
                            iapManager.purchaseCredits(productID: Constants.IAPProductIdentifiers.credits120)
                        }
                        
                        PurchaseButton(title: "200 Credits for $2.99", isProcessing: $iapManager.isProcessingPurchase) {
                            iapManager.purchaseCredits(productID: Constants.IAPProductIdentifiers.credits200)
                        }
                        
                        PurchaseButton(title: "300 Credits for $3.99", isProcessing: $iapManager.isProcessingPurchase) {
                            iapManager.purchaseCredits(productID: Constants.IAPProductIdentifiers.credits300)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 14))  // Smaller text size
                                .frame(maxWidth: .infinity)  // Make the button fill the available width
                                .padding(.vertical, 8)  // Reduce vertical padding
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        
                    }
                    .padding()
                    
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
            .navigationTitle("Purchase Credits")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $iapManager.showAlert) {
                Alert(title: Text("Purchase Failed"),
                      message: Text(iapManager.alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            iapManager.isProcessingPurchase = false
        }
    }

}


#Preview {
    InAppPurchaseView()
}
