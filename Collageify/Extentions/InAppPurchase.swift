//
//  InAppPurchase.swift
//  FourBars
//
//

import SwiftyStoreKit
import UIKit

enum RegisteredPurchase: String {
    case autoRenewableForMonth = "com.photo.collageify.monthly" //
    case autoRenewableForYear = "com.photo.collageify.yearly" //
    case autoRenewableForLifeTime = "com.photo.collageify.lifetime" //
    case sharedSecret = "92e8618f6ba44f32a220127839fff8d2"
}

var isSubScription: Bool = Bool()

class InAppPurchase: NSObject {
    
    let controller = UIApplication.topMostViewController() ?? UIViewController()

    func getInfo(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.controller.showAlert(self.controller.alertForProductRetrievalInfo(result))
        }
    }

    func purchase(_ purchase: RegisteredPurchase, atomically: Bool, completion: @escaping (Bool) -> Void) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(purchase.rawValue, atomically: atomically, simulatesAskToBuyInSandbox: false) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if case let .success(purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                if purchase.productId == RegisteredPurchase.autoRenewableForMonth.rawValue {
                    isSubScription = true
                    self.verifyPurchase(.autoRenewableForMonth)
                } else if purchase.productId == RegisteredPurchase.autoRenewableForYear.rawValue {
                    isSubScription = true
                    self.verifyPurchase(.autoRenewableForYear)
                }
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                completion(true)
                return
            }
            completion(false)
        }
    }

    func restorePurchases(completion: @escaping (RestoreResults) -> Void) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
//            for purchase in results.restoredPurchases {
//                let downloads = purchase.transaction.downloads
//                if !downloads.isEmpty {
//                    SwiftyStoreKit.start(downloads)
//                    completion()
//                } else if purchase.needsFinishTransaction {
//                    // Deliver content from server, then:
//                    SwiftyStoreKit.finishTransaction(purchase.transaction)
//                }
//            }
            let restoreResults = RestoreResults(restoredPurchases: results.restoredPurchases, restoreFailedPurchases: results.restoreFailedPurchases)
            completion(restoreResults)
//                self.controller.showAlert(self.controller.alertForRestorePurchases(results))
        }
    }

    func verifyReceipt() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: RegisteredPurchase.sharedSecret.rawValue) // "e60e55c6b9b14a56a25a4280d35af834"
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { _ in
            NetworkActivityIndicatorManager.networkOperationFinished()
//            self.controller.showAlert(self.controller.alertForVerifyReceipt(result))
        }
    }

    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: RegisteredPurchase.sharedSecret.rawValue)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }

    func verifyPurchase(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { [self] result in
            NetworkActivityIndicatorManager.networkOperationFinished()

            switch result {
            case let .success(receipt):

                let productId = purchase.rawValue

                switch purchase {
                case .autoRenewableForMonth:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt
                    )
                    self.controller.showAlert(controller.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
                case .autoRenewableForYear:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt
                    )
                    self.controller.showAlert(controller.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
//                case .nonRenewingPurchase:
//                    let purchaseResult = SwiftyStoreKit.verifySubscription(
//                        ofType: .nonRenewing(validDuration: 60),
//                        productId: productId,
//                        inReceipt: receipt)
//                    controller.showAlert(controller.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
                default:
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: productId,
                        inReceipt: receipt
                    )
                    controller.showAlert(controller.alertForVerifyPurchase(purchaseResult, productId: productId))
                }

            case .error:
//                controller.showAlert(controller.alertForVerifyReceipt(result))
                break
            }
        }
    }

    func verifySubscriptions(_ purchases: Set<RegisteredPurchase>, completion: @escaping (Bool) -> Void) {
//        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: RegisteredPurchase.sharedSecret.rawValue)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            NetworkActivityIndicatorManager.networkOperationFinished()

            switch result {
            case let .success(receipt):
                let productIds = Set(purchases.map { $0.rawValue })
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                var isSubscribed = self.checkIFAlreadySubscribed(purchaseResult, productIds: productIds)
                completion(isSubscribed)
            case .error:
                completion(false)
//                if let topController = UIApplication.topViewController() {
//                    topController.showAlert(topController.alertForVerifyReceipt(result))
//                }
            }
        }
    }

    func checkIFAlreadySubscribed(_ result: VerifySubscriptionResult, productIds: Set<String>) -> Bool {
        switch result {
        case let .purchased(expiryDate, items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return true
        case let .expired(expiryDate, items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return false
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return false
        }
    }
}

class NetworkActivityIndicatorManager: NSObject {
    private static var loadingCount = 0
    private static var indicator: MaterialActivityIndicatorView!

    class func networkOperationStarted() {
        //        ProgressHUD.showSuccess("Please wait...", image: UIImage(named: "ic_logo"), interaction: false)
        //        ProgressHUD.show("Please wait...", interaction: false)
        let view = UIWindow.key!
        if view.subviews.contains(where: { $0.tag == 1001 }) {
            print("Already Done --- ")
        } else {
            indicator = MaterialActivityIndicatorView(frame: view.bounds)
//            indicator.image = UIImage.gifImageWithName("loader") ?? UIImage()
            indicator.tag = 1001
            indicator.color = .clear // UIColor(named: "IndicatorColor") ?? .systemBlue
            view.addSubview(indicator)
        }
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }

    class func networkOperationFinished() {
        //        ProgressHUD.dismiss()
        indicator.stopAnimating()
    }
}
