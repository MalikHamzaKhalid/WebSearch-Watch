//
//  PurchaseButton.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 06/09/2024.
//

import SwiftUI

struct PurchaseButton: View {
    var title: String
    @Binding var isProcessing: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            if !isProcessing {
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isProcessing)
    }
}

#Preview {
    PurchaseButton(title: "Button", isProcessing: .constant(false)) {
        
    }
}
