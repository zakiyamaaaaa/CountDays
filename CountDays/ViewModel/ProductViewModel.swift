//
//  ProductViewModel.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/08/31.
//

import Foundation
import StoreKit

final class ProductViewModel: ObservableObject {
    @Published var product: Product?
    
    func fetchProducts(_ productId: String) async throws -> [Product] {
        
        return try await Product.products(for: [productId])
    }
    
    func purchase(product: Product) async throws -> Transaction {
        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await product.purchase()
        } catch Product.PurchaseError.productUnavailable {
            throw SubscribeError.productUnavailable
        } catch Product.PurchaseError.purchaseNotAllowed {
            throw SubscribeError.purchaseNotAllowed
        } catch {
            throw SubscribeError.otherError
        }
        
        let verificationResult: VerificationResult<Transaction>
        switch purchaseResult {
        case .success(let result):
            verificationResult = result
        case .userCancelled:
            throw SubscribeError.userCanceled
        case .pending:
            throw SubscribeError.pending
        @unknown default:
            throw SubscribeError.otherError
        }
        
        switch verificationResult {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw SubscribeError.failedVerification
        }
    }
}

enum SubscribeError: LocalizedError {
    case userCanceled
    case pending
    case productUnavailable
    case purchaseNotAllowed
    case failedVerification
    case otherError
}
