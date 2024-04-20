import UIKit
import SwiftyStoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max) // Enable debug mode
        setupIAP()
        fetchAndStoreRemoteConfig()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }

    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }

        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }

    func fetchAndStoreRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()

        let fetchDuration: TimeInterval = 3600
        remoteConfig.fetch(withExpirationDuration: fetchDuration) { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate()
                if let adUnitID1 = remoteConfig["bannerAdID"].stringValue,
                   let adUnitID2 = remoteConfig["rewardAdID"].stringValue {
                    UserDefaults.standard.set(adUnitID1, forKey: "BANNER_ID")
                    UserDefaults.standard.set(adUnitID2, forKey: "REWARD_ID")
                }

                let adsEnabled = remoteConfig["isAdsShow"].boolValue
                print("adsEnabled: \(adsEnabled)")
                if adsEnabled == true {
                    IS_ADS_SHOW = true
                } else {
                    IS_ADS_SHOW = false
                }
            } else {
                print("Error fetching remote config: \(error?.localizedDescription ?? "")")
                // Handle error
            }
        }
    }
}
