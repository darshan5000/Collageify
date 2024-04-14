import UIKit

class PurchaseViewController: UIViewController {

//    private var inAppPurchase = InAppPurchase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
//    @IBAction func termOfUseBtn(_ sender: UIButton) {
//        openUrl(urlString: "https://collageappprivacypolicy.blogspot.com/2024/03/terms-of-use-welcome-to-piccollagepro.html")
//    }
//    
//    @IBAction func privacyPolicy(_ sender: Any) {
//        openUrl(urlString: "https://collageappprivacypolicy.blogspot.com/2024/03/privacy-policy-at-piccollagepro-we.html")
//    }
//    
//    
//    
//    func openUrl(urlString: String) {
//        guard let url = URL(string: urlString) else {
//          return //be safe
//        }
//
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
//    }
//    
//    @IBAction func subscribeBtn(_ sender: UIButton) {
//        inAppPurchase.purchase(.autoRenewableForMonth, atomically: true) { isPurchased in
//            isSubScription = isPurchased
//            userDefault.set(isSubScription, forKey: "isSubScription")
//            if isSubScription == true {
//                self.dismiss(animated: true)
//            }
//        }
//    }
//    
//    @IBAction func restoreBtn(_ sender: UIButton) {
//        inAppPurchase.restorePurchases { restoreResults in
//            if restoreResults.restoredPurchases.isEmpty && restoreResults.restoreFailedPurchases.isEmpty {
//                // Show popup for no restored products and no failed purchase attempts
//                self.showPopup(message: "No products were restored and no purchase attempts failed.") {
//                }
//            } else if restoreResults.restoredPurchases.isEmpty {
//                // Show popup for no restored products
//                self.showPopup(message: "No products were restored.") {
//                }
//            } else if restoreResults.restoreFailedPurchases.isEmpty {
//                // Show popup for no failed purchase attempts
//                self.showPopup(message: "All products were successfully restored, but no purchase attempts failed.") {
//                    self.dismiss(animated: false)
//                }
//            } else {
//                // Handle individual failed purchase attempts
//                for (error, productIdentifier) in restoreResults.restoreFailedPurchases {
//                    let identifier = productIdentifier ?? "Unknown"
//                    let errorMessage = "Failed to restore purchase with product identifier: \(identifier) - Error: \(error.localizedDescription)"
//                    print(errorMessage) // You can log the error messages if needed
//                }
//            }
//        }
//    }
//    
//    func showPopup(message: String, completion: @escaping () ->Void) {
//        let alertController = UIAlertController(title: "Restore Results", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            completion()
//        }))
//        // Present the alert
//        
//        self.present(alertController, animated: true, completion: nil)
//        
//    }
//    
//    
//    @IBAction func subscribeYearBtn(_ sender: UIButton) {
//        inAppPurchase.purchase(.autoRenewableForYear, atomically: true) { isPurchased in
//            isSubScription = isPurchased
//            userDefault.set(isSubScription, forKey: "isSubScription")
//            if isSubScription == true {
//                self.dismiss(animated: true)
//            }
//        }
//    }

    
}
