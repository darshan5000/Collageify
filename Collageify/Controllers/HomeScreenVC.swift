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

class HomeScreenVC: UIViewController, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    //MARK:- outlets
    @IBOutlet weak var btnMyAlbums: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let engine = AVAudioEngine()
    var arrayAsset : [VideoData] = []
    var allAssets : [DKAsset] = []
    var index = 0
    let group = DispatchGroup()
    var appOpenAd: GADAppOpenAd?
    var loadTime: Date?
    
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("HomeScreenVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adDismissed), name: NSNotification.Name("AdDismissedNotification"), object: nil)
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
        if IS_ADS_SHOW == true {
            if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID1
            }
            
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
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
        let textToShare = "Check out this awesome app!"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // necessary for iPad
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func onTappedRateus(_ sender: Any) {
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
        let obj : ALLShapeVC = self.storyboard?.instantiateViewController(withIdentifier: "LoadShapesVC") as! ALLShapeVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        let obj = self.storyboard!.instantiateViewController(withIdentifier: "PresentPhotoVC") as! CurrentPhotoVC
        obj.objSelectiontype = 2
        let navController = UINavigationController(rootViewController: obj)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func btnMyAlbumsAction(_ sender: Any) {
        let obj : MyPhotosVC = self.storyboard?.instantiateViewController(withIdentifier: "MyAlbumVC") as! MyPhotosVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnActionReel(_ sender: Any) {
        openImagePickerView()
//        self.openSpotifyController()
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
        let vc = storyBoard.instantiateViewController(withIdentifier: "SongListViewController") as! SongListViewController
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
                
                videoData.image = image
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
                        if AuthManager.shared.isSignedIn {
                            self.openSpotifyController()
                        } else {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let vc = storyBoard.instantiateViewController(withIdentifier: "SpotifySignInViewController") as! SpotifySignInViewController
                            vc.isSignInSuccess = {
                                self.dismiss(animated: true) {
                                    self.openSpotifyController()
                                }
                            }
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
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
                                self.saveReel(url, false)
                            }
                            let preview = UIAlertAction(title: "Preview", style: UIAlertAction.Style.default, handler: { action in
                                self.saveReel(url, true)
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
// MARK: - GADFullScreenContentDelegate
extension HomeScreenVC {
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Ad did record impression")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content:", error)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
    }
}
