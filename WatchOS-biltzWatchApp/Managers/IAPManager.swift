//
//  IAPManager.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 02/09/2024.
//

import StoreKit

class IAPManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate, ObservableObject {
    static let shared = IAPManager()
    
    @Published var isProcessingPurchase = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // Method to purchase a product
    func purchaseCredits(productID: String) {
        if SKPaymentQueue.canMakePayments() {
            isProcessingPurchase = true
            let request = SKProductsRequest(productIdentifiers: Set([productID]))
            request.delegate = self
            request.start()
        } else {
            alertMessage = "Purchases are disabled on this device."
            showAlert = true
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.isProcessingPurchase = false
        }
        if let product = response.products.first {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            alertMessage = "We couldn't retrieve the product information. Please check your internet connection and try again."
            showAlert = true
        }
    }
    
    private func retryProductRequest() {
        // Retry the product request
        let productIdentifiers = Set([Constants.IAPProductIdentifiers.credits120, Constants.IAPProductIdentifiers.credits200, Constants.IAPProductIdentifiers.credits300])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self  // Set the delegate again
        request.start()
    }
    
    // Restore purchases method
    func restorePurchases() {
        isProcessingPurchase = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // Delegate method for restored transactions
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.isProcessingPurchase = false
            self.alertMessage = "Restore failed: \(error.localizedDescription)"
            self.showAlert = true
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.isProcessingPurchase = false
            if queue.transactions.isEmpty {
                self.alertMessage = "No purchases to restore."
            } else {
                self.alertMessage = "Purchases successfully restored."
            }
            self.showAlert = true
        }
    }

    // Handles transaction updates, including purchases and restores
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            default:
                break
            }
        }
    }

    // Handle purchase completion
    private func complete(transaction: SKPaymentTransaction) {
        deliverCredits(for: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        isProcessingPurchase = false
        alertMessage = "Purchase completed: \(transaction.payment.productIdentifier)"
        showAlert = true
    }

    // Handle restore of previously purchased items
    private func restore(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        alertMessage = "Restored: \(transaction.payment.productIdentifier)"
        isProcessingPurchase = false
        showAlert = true
    }

    // Handle failed purchases
    private func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            alertMessage = "Purchase failed: \(error.localizedDescription)"
        } else {
            alertMessage = "Purchase failed."
        }
        isProcessingPurchase = false
        showAlert = true
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverCredits(for productIdentifier: String) {
        switch productIdentifier {
        case Constants.IAPProductIdentifiers.credits120:
            UserManager.shared.initCredits(by: Constants.Credits.creditsFor120Purchase)
        case Constants.IAPProductIdentifiers.credits200:
            UserManager.shared.initCredits(by:Constants.Credits.creditsFor200Purchase)
        case Constants.IAPProductIdentifiers.credits300:
            UserManager.shared.initCredits(by:Constants.Credits.creditsFor300Purchase)
        default:
            break
        }
    }
}

extension IAPManager {
    
    func checkBonusCredits() {
        let bonusKey = "bonusCredits"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: bonusKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            let result = dataTypeRef as! Data
            let hasUsedBonusCredits = String(data: result, encoding: .utf8)
            if hasUsedBonusCredits == "true" {
                print("User has already used bonus credits.")
            } else {
                print("User has not used bonus credits.")
            }
        } else {
            print("User has not received bonus credits yet.")
        }

    }
    
}
