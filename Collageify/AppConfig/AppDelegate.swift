import UIKit
import SwiftyStoreKit
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {
    
    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    var loadTime: Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max) // Enable debug mode
        setupIAP()
        fetchAndStoreRemoteConfig()
        loadAppOpenAdIfNeeded()
        return true
    }
    
    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
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
                   let adUnitID2 = remoteConfig["rewardAdID"].stringValue,
                   let adUnitID3 = remoteConfig["openAppAdID"].stringValue {
                    UserDefaults.standard.set(adUnitID1, forKey: "BANNER_ID")
                    UserDefaults.standard.set(adUnitID2, forKey: "REWARD_ID")
                    UserDefaults.standard.set(adUnitID3, forKey: "OPENAD_ID")
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
            }
        }
    }
    
    func loadAppOpenAdIfNeeded() {
        if !isAdAlreadyShownInSession() {
            loadAppOpenAd()
        }
    }
    
    func loadAppOpenAd() {
        let adUnitID = "ca-app-pub-3940256099942544/5575463023" // Replace with your Ad Unit ID
        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest(), orientation: UIInterfaceOrientation.portrait, completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load App Open Ad: \(error.localizedDescription)")
                return
            }
            
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            
            // Show the ad
            self.showAppOpenAdIfReady()
        })
    }
    
    func showAppOpenAdIfReady() {
        if let appOpenAd = appOpenAd, let rootViewController = window?.rootViewController {
            appOpenAd.present(fromRootViewController: rootViewController)
            saveAdShownTimestamp()
        } else {
            print("App Open Ad is not ready yet.")
        }
    }
    
    func isAdAlreadyShownInSession() -> Bool {
        if let loadTime = loadTime {
            let currentTime = Date()
            let elapsedTime = currentTime.timeIntervalSince(loadTime)
            return elapsedTime < 3600 // Assuming the ad should not be shown again within 1 hour (3600 seconds)
        }
        return false
    }
    
    func saveAdShownTimestamp() {
        loadTime = Date()
    }
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        NotificationCenter.default.post(name: NSNotification.Name("AdDismissedNotification"), object: nil)
    }
}
