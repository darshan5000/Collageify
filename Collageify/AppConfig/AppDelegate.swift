import UIKit
import SwiftyStoreKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {
    
    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    var loadTime: Date?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("enable tracking")
                case .denied:
                    print("disable tracking")
                default:
                    print("disable tracking")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.max) // Enable debug mode
        fetchAndStoreRemoteConfig()
        setupIAP()
        if IS_ADS_SHOW == true {
            loadAppOpenAdIfNeeded()
        }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if IS_ADS_SHOW == true {
            loadAppOpenAdIfNeeded()
            print("APP COMES FROM BG >>>>>>>>>>>>>>>>>>>>")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if IS_ADS_SHOW == true {
        onlyLoadAppOpenAd()
        }
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
        
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate()
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: "BANNER_ID")
                userDefaults.removeObject(forKey: "REWARD_ID")
                userDefaults.removeObject(forKey: "OPENAD_ID")
                userDefaults.removeObject(forKey: "AD_COUNT")
                userDefaults.removeObject(forKey: "INTERSTITIAL_ID")
                
                if let adUnitID1 = remoteConfig["bannerAdID"].stringValue,
                   let adUnitID2 = remoteConfig["rewardAdID"].stringValue,
                   let adUnitID3 = remoteConfig["openAppAdID"].stringValue,
                   let adUnitID4 = remoteConfig["interstitialAdID"].stringValue,
                   let adsCount = remoteConfig["adsCount"].stringValue {
                    
                    userDefaults.set(adUnitID1, forKey: "BANNER_ID")
                    userDefaults.set(adUnitID2, forKey: "REWARD_ID")
                    userDefaults.set(adUnitID3, forKey: "OPENAD_ID")
                    userDefaults.set(adsCount, forKey: "AD_COUNT")
                    userDefaults.set(adUnitID4, forKey: "INTERSTITIAL_ID")
                    
                    print("Ads Count From Firebase:-----\(adsCount)")
                    print("BANNER_ID >>>>>>>>>>>>>> \(adUnitID1)")
                    print("REWARD_ID >>>>>>>>>>>>>> \(adUnitID2)")
                    print("OPENAD_ID >>>>>>>>>>>>>> \(adUnitID3)")
                    print("INTERSTITIAL_ID >>>>>>>>>>>>>> \(adUnitID4)")
                }
                
                let adsEnabled = remoteConfig["isAdsShow"].boolValue
                print("adsEnabled: \(adsEnabled)")
                IS_ADS_SHOW = adsEnabled // Directly assign the value without needing an if-else block
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
        let adUnitID = "ca-app-pub-3940256099942544/5575463023"
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
    func onlyLoadAppOpenAd() {
        let adUnitID = "ca-app-pub-3940256099942544/5575463023"
        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest(), orientation: UIInterfaceOrientation.portrait, completionHandler: { (ad, error) in
            if let error = error {
                print("Failed to load App Open Ad: \(error.localizedDescription)")
                return
            }
            
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
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
        onlyLoadAppOpenAd()
        NotificationCenter.default.post(name: NSNotification.Name("AdDismissedNotification"), object: nil)
    }
}
