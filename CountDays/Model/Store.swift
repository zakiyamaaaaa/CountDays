//
//  Store.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/04.
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

public enum SubscriptionTier: Int, Comparable {
    public static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case normal = 0
    case `super` = 1
    case premium = 2
    
    var string: String {
        switch self {
        case .normal:
            return "ノーマル"
        case .super:
            return "Super"
        case .premium:
            return "Premium"
        }
    }
}

class Store: ObservableObject {
    @Published private(set) var subscriptions: [Product]
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        subscriptions = []
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            var newSubscriptions: [Product] = []
            let storeProducts = try await Product.products(for: [""])
            
            for product in storeProducts {
                switch product.type {
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    print("Unknown Product")
                }
            }
            
            self.subscriptions = newSubscriptions
            
        } catch {
            print("failed product request from the app store server")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func fetchProducts(_ productId: String) async throws -> [Product] {
        return try await Product.products(for: [productId])
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// こっちなぜかうまく動作しない
//    func isPurchased(_ product: Product) async throws -> Bool {
//        switch product.type {
//        case .autoRenewable:
//            return purchasedSubscriptions.contains(product)
//        default:
//            return false
//        }
//    }
    
    func isPurchased(_ identifier: String) async throws -> Bool {
        guard let result = await Transaction.latest(for: identifier) else {
            return false
        }
        let transaction = try checkVerified(result)
        
        /// ここでRealmのUserモデルのグレードプロパティを更新
        /// ここで更新するのがいいのかは要検討
        RealmModel.updateGrade(grade: self.tier(for: identifier).rawValue)
        
        return transaction.revocationDate == nil && !transaction.isUpgraded
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID
                    }){
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                print()
            }
        }
        
        self.purchasedSubscriptions = purchasedSubscriptions
        
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
    }
    
    func tier(for productId: String) -> SubscriptionTier {
        switch productId {
        case "com.temporary.id":
            return .super
        case "subscription.premium":
            return .premium
        default:
            return .normal
        }
    }
    
}
