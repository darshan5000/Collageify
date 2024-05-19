import UIKit
import StoreKit
import AVKit
import DKImagePickerController
import SVProgressHUD
import AVFoundation
import MediaPlayer
import Photos
import MediaPlayer
import Foundation
import CryptoKit
import Firebase
import GoogleMobileAds
import FirebaseRemoteConfig
import Security
import Lottie

class HomeScreenVC: UIViewController, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    //MARK:- outlets
    @IBOutlet weak var btnMyAlbums: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var animationContainerView: LottieAnimationView!
    
    let engine = AVAudioEngine()
    var arrayAsset : [VideoData] = []
    var allAssets : [DKAsset] = []
    var index = 0
    let group = DispatchGroup()
    var appOpenAd: GADAppOpenAd?
    var loadTime: Date?
    private var rewardAd: GADRewardedAd?
    var adWasShown: Bool = false
    var rewardAdid = ""
    private var interstitial: GADInterstitialAd?
    var isOfferGot: Bool = false
    var isVipBtnTap: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("HomeScreenVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
        
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            if let adUnitID = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID
                bannerView.rootViewController = self
                bannerView.load(GADRequest())
                bannerView.delegate = self
                bannerView.isHidden = false
            } else {
                print("No ad unit ID found in UserDefaults")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if IS_ADS_SHOW == true {
            loadRewardAd()
            loadInterstitial()
            TriggerOpenAppAd()
        }
        if let savedCount = retrieveCountFromKeychain() {
            REEL_COUNT = savedCount
        }
        NotificationCenter.default.addObserver(self, selector: #selector(adDismissed), name: NSNotification.Name("AdDismissedNotification"), object: nil)
        InAppPurchase().verifySubscriptions([.autoRenewableForMonth, .autoRenewableForYear, .autoRenewableForLifeTime], completion: { isPurchased in
            isSubScription = isPurchased
            userDefault.set(isSubScription, forKey: "isSubScription")
            isSubScription = userDefault.bool(forKey: "isSubScription")
            if isSubScription == false {
                self.loadRewardAd()
                let obj : InAppPurchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchaseVC") as! InAppPurchaseVC
                let navController = UINavigationController(rootViewController: obj)
                navController.navigationBar.isHidden = true
                navController.modalPresentationStyle = .overCurrentContext
                self.present(navController, animated:true, completion: nil)
            }
        })
        
        animationContainerView.contentMode = .scaleToFill
        animationContainerView.loopMode = .loop
        animationContainerView.animationSpeed = 1
        animationContainerView.play()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animationViewTapped))
        animationContainerView.addGestureRecognizer(tapGesture)
        animationContainerView.isUserInteractionEnabled = true
        
    }
    @objc func adDismissed() {
        InAppPurchase().verifySubscriptions([.autoRenewableForMonth, .autoRenewableForYear, .autoRenewableForLifeTime], completion: { isPurchased in
            isSubScription = isPurchased
            userDefault.set(isSubScription, forKey: "isSubScription")
            isSubScription = userDefault.bool(forKey: "isSubScription")
            if isSubScription == false {
                let obj : InAppPurchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchaseVC") as! InAppPurchaseVC
                let navController = UINavigationController(rootViewController: obj)
                navController.navigationBar.isHidden = true
                navController.modalPresentationStyle = .overCurrentContext
                self.present(navController, animated:true, completion: nil)
            }
        })
    }
    
    
    //MARK:- Button Action Zone
    @IBAction func onTappedShareApp(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                CLICK_COUNT = 0
                TrigerInterstitial()
            }
        }
        let textToShare = "https://apps.apple.com/in/app/collageify/id6482987481"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // necessary for iPad
        
        present(activityViewController, animated: true, completion: nil)
    }
    @objc func animationViewTapped() {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            showAlertForGift()
        } else {
            showCongratulationAlert()
        }
    }
    @IBAction func onTappedPointsBtn(_ sender: Any) {
        
        //        CLICK_COUNT += 1
        //        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
        //            TrigerInterstitial()
        //            CLICK_COUNT = 0
        //        }
        //        let vc = storyboard?.instantiateViewController(withIdentifier: "CoinsCollecVC") as! CoinsCollecVC
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTappedRateus(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                CLICK_COUNT = 0
                TrigerInterstitial()
            }
        }
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "com.photo.collageify") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onTappedVIPBtn(_ sender: Any) {
        let obj : InAppPurchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchaseVC") as! InAppPurchaseVC
        let navController = UINavigationController(rootViewController: obj)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .flipHorizontal
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func btnGridAction(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                CLICK_COUNT = 0
                TrigerInterstitial()
                print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            }
        }
        let obj : ALLShapeVC = self.storyboard?.instantiateViewController(withIdentifier: "LoadShapesVC") as! ALLShapeVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func sizeInMB(data: Data) -> Int {
        let bytes = Double(data.count)
        let megabytes = bytes / (1024 * 1024)
        return Int(megabytes)
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                TrigerInterstitial()
                CLICK_COUNT = 0
                print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            }
        }
        let obj = self.storyboard!.instantiateViewController(withIdentifier: "CurrentPhotoVC") as! CurrentPhotoVC
        obj.objSelectiontype = 2
        let navController = UINavigationController(rootViewController: obj)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func btnMyAlbumsAction(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                TrigerInterstitial()
                CLICK_COUNT = 0
                print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            }
        }
        let obj : MyPhotosVC = self.storyboard?.instantiateViewController(withIdentifier: "MyAlbumVC") as! MyPhotosVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnActionReel(_ sender: Any) {
        if IS_ADS_SHOW == true {
            loadInterstitial()
            loadRewardAd()
            CLICK_COUNT += 1
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
                CLICK_COUNT = 0
                TrigerInterstitial()
                print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            }
        }
        //        self.openSpotifyController()
        
        openImagePickerView()
        
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let vc = storyBoard.instantiateViewController(withIdentifier: "VideoTrimViewController") as! VideoTrimViewController
        //        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true)
    }
    
    func openImagePickerView() {
        let picker = DKImagePickerController()
        picker.assetType = .allAssets
        picker.showsEmptyAlbums = false
        picker.showsCancelButton = true
        picker.allowsLandscape = false
        picker.maxSelectableCount = 10
        picker.sourceType = .photo
        picker.navigationBar.backgroundColor = .white
        picker.view.backgroundColor = .white
        picker.modalPresentationStyle = .fullScreen
        
        picker.didSelectAssets = {[weak self] (assets: [DKAsset]) in
            guard let `self` = self, assets.count > 0 else {return}
            self.arrayAsset = []
            self.allAssets = []
            self.index = 0
            self.allAssets = assets
            self.showProcessing(isShow: true)
            self.getArrayAssets(indexx: 0, asset: assets[0])
        }
        present(picker, animated: true, completion: nil)
    }
    
    func openSpotifyController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SongSearchViewController") as! SongSearchViewController
        vc.selectedURL = {
            self.showProcessing(isShow: true)
            self.mergeVideosAndImages(arrayData: self.arrayAsset)
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func getArrayAssets(indexx: Int, asset: DKAsset) {
        var videoData = VideoData()
        videoData.index = index
        index += 1
        
        if asset.type == .video {
            videoData.isVideo = true
            group.enter()
            asset.fetchAVAsset { (avAsset, info) in
                guard let avAsset = avAsset else {
                    self.group.leave()
                    return
                }
                
                videoData.asset = avAsset
                self.arrayAsset.append(videoData)
                self.group.leave()
                self.mergeProccess()
            }
        } else {
            group.enter()
            asset.fetchOriginalImage { (image, info) in
                guard let image = image else {
                    self.group.leave()
                    return
                }
                
                if self.sizeInMB(data: image.pngData() ?? Data()) > 15 {
                    let thumb1 = image.resized(withPercentage: 0.5)
                    print(self.sizeInMB(data: thumb1!.pngData()!))
                    videoData.image = thumb1
                } else {
                    videoData.image = image
                }
                
                self.arrayAsset.append(videoData)
                self.group.leave()
                self.mergeProccess()
            }
        }
    }
    
    func mergeProccess() {
        if self.index == self.allAssets.count {
            self.showProcessing(isShow: false)
            DispatchQueue.main.async {
                let obj : EditReelsViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditReelsViewController") as! EditReelsViewController
                obj.arrayAsset = self.arrayAsset
                obj.actionDone = { array in
                    let alert = UIAlertController(title: "Do you want to add music on reel", message: nil, preferredStyle: .alert)
                    let save = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { _ in
                        //                        if AuthManager.shared.isSignedIn {
                        self.openSpotifyController()
                        //                        } else {
                        //                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        //                            let vc = storyBoard.instantiateViewController(withIdentifier: "SpotifySignInViewController") as! SpotifySignInViewController
                        //                            vc.isSignInSuccess = {
                        //                                self.dismiss(animated: true) {
                        //                                    self.openSpotifyController()
                        //                                }
                        //                            }
                        //                            vc.modalPresentationStyle = .fullScreen
                        //                            self.present(vc, animated: true)
                        //                        }
                    }
                    let preview = UIAlertAction(title: "Create Reel", style: UIAlertAction.Style.default, handler: { action in
                        self.showProcessing(isShow: true)
                        self.mergeVideosAndImages(arrayData: array)
                    })
                    alert.addAction(save)
                    alert.addAction(preview)
                    self.present(alert, animated: true, completion: nil)
                }
                self.navigationController?.pushViewController(obj, animated: true)
            }
        } else {
            self.getArrayAssets(indexx: self.index, asset: self.allAssets[self.index])
        }
    }
    
    private func mergeVideosAndImages(arrayData: [VideoData]) {
        DispatchQueue.global().async {
            VideoManager.shared.makeVideoFrom(data: arrayData, completion: {[weak self] (outputURL, error) in
                guard let `self` = self else { return }
                self.showProcessing(isShow: false)
                if let error = error {
                    print("Error:\(error.localizedDescription)")
                } else if let url = outputURL {
                    DispatchQueue.main.async {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            let alert = UIAlertController(title: "Your reel is ready", message: nil, preferredStyle: .alert)
                            let save = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) { _ in
                                self.showRewardAd()
                                REEL_COUNT += 1
                                self.saveCountToKeychain(count: REEL_COUNT)
                                
                                if REEL_COUNT > 5 {
                                    // Show alert
                                    let alertController = UIAlertController(title: "Limit Exceeded", message: "You've used the reels more than 5 times.", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    // Save the updated count to Keychain
                                    self.saveCountToKeychain(count: REEL_COUNT)
                                    self.saveReel(url, false)
                                }
                            }
                            let preview = UIAlertAction(title: "Preview", style: UIAlertAction.Style.default, handler: { action in
                                self.saveReel(url, true)
                                if IS_ADS_SHOW == true {
                                    self.showRewardAd()
                                }
                            })
                            alert.addAction(save)
                            alert.addAction(preview)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func saveReel(_ url: URL!, _ isPreview : Bool) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                        let newObj = avurlAsset as! AVURLAsset
                        print(newObj.url)
                        DispatchQueue.main.async {
                            if isPreview {
                                self.openPreviewScreen(url)
                            } else {
                                let alert = UIAlertController(title: "Reel downloaded", message: nil, preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func showProcessing(isShow: Bool) {
        if isShow {
            SVProgressHUD.show()
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
    private func openPreviewScreen(_ videoURL:URL) -> Void {
        let player = AVPlayer(url: videoURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.modalPresentationStyle = .fullScreen
        
        present(playerController, animated: true, completion: {
            player.play()
        })
    }
}

extension HomeScreenVC {
    
    func loadRewardAd() {
        if let adUnitID1 = UserDefaults.standard.string(forKey: "REWARD_ID") {
            print("REWARD_ID \(adUnitID1)")
            GADRewardedAd.load(withAdUnitID: adUnitID1,
                               request: GADRequest()) { ad, error in
                if let error = error {
                    print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                    return
                }
                self.rewardAd = ad
                self.rewardAd?.fullScreenContentDelegate = self
            }
        }
        
    }
    func showRewardAd() {
        if let rewardAd = self.rewardAd {
            rewardAd.present(fromRootViewController: self) {
            }
        } else {
            print("Ad wasn't ready")
        }
    }
}

extension HomeScreenVC {
    func saveCountToKeychain(count: Int) {
        let countData = Data("\(count)".utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.photo.collageify", // Use your own unique service name
            kSecAttrAccount as String: "REEL_COUNT",
            kSecValueData as String: countData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save count to Keychain")
        }
    }
    
    // Function to retrieve count from Keychain
    func retrieveCountFromKeychain() -> Int? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.photo.collageify",
            kSecAttrAccount as String: "REEL_COUNT",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data, let countString = String(data: data, encoding: .utf8), let count = Int(countString) {
            return count
        } else {
            print("Failed to retrieve count from Keychain")
            return nil
        }
    }
    
}

extension HomeScreenVC {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        loadInterstitial()
        loadRewardAd()
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadRewardAd()
        loadInterstitial()
        print("Ad did present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadRewardAd()
        loadInterstitial()
        if isOfferGot == true {
            self.showCongratulationAlert()
        }
        print("Ad did dismiss full screen content.")
        
    }
    
    func showAlertForGift() {
        self.animationContainerView.isHidden = true
        let alert = UIAlertController(title: "Special Offer!", message: "Unlock a 50% discount by watching a quick ad!", preferredStyle: .alert)
        
        let watchAction = UIAlertAction(title: "Watch Now", style: .default) { (_) in
            self.isOfferGot = true
            self.showRewardAd()
            
        }
        alert.addAction(watchAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.animationContainerView.isHidden = false
        }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    func showCongratulationAlert() {
        self.animationContainerView.isHidden = true
        self.isOfferGot = false
        let alert = UIAlertController(title: "Congratulations!", message: "You've successfully unlocked a special offer! 🎉 Enjoy your 50% discount!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let obj : InAppPurchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchaseVC") as! InAppPurchaseVC
            let navController = UINavigationController(rootViewController: obj)
            navController.navigationBar.isHidden = true
            navController.modalPresentationStyle = .overCurrentContext
            self.present(navController, animated:true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func loadInterstitial() {
        let adRequest = GADRequest()
        if let adUnitID1 = UserDefaults.standard.string(forKey: "INTERSTITIAL_ID") {
            GADInterstitialAd.load(withAdUnitID: adUnitID1, request: adRequest) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
            }
        }
    }
    
    func TrigerInterstitial() {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Interstitial ad is not ready yet.")
        }
    }
    func TriggerOpenAppAd() {
        let adUnitID = "ca-app-pub-3940256099942544/5575463023" // Example ad unit ID, replace it with your own
            
            // Request the ad
            GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest(), orientation: .portrait) { (ad, error) in
                if let error = error {
                    print("Failed to load App Open Ad: \(error.localizedDescription)")
                    return
                }
                
                // Ad loaded successfully
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                
                // Present the ad, if available
                if let appOpenAd = self.appOpenAd {
                    appOpenAd.present(fromRootViewController: self)
                } else {
                    print("App Open ad is nil")
                }
            }
    }
    
}
