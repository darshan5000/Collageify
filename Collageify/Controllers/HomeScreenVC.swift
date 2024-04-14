import UIKit
import StoreKit
import AVKit
import DKImagePickerController
import SVProgressHUD
import AVFoundation
import MediaPlayer
import Photos

class HomeScreenVC: UIViewController {

    //MARK:- outlets
    @IBOutlet weak var btnMyAlbums: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    let engine = AVAudioEngine()
    var audioUrl : URL?
    var arrayAsset : [VideoData] = []
    var allAssets : [DKAsset] = []
    var index = 0
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        openAppleMusicLibrary()
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
    
    func openAppleMusicLibrary() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.showsItemsWithProtectedAssets = false // These items usually cannot be played back
        mediaPicker.showsCloudItems = false // MPMediaItems stored in the cloud don't have an assetURL
        mediaPicker.delegate = self
        mediaPicker.prompt = "Pick a music"
        present(mediaPicker, animated: true, completion: nil)
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
            self.mergeVideosAndImages(arrayData: self.arrayAsset)
        } else {
            self.getArrayAssets(indexx: self.index, asset: self.allAssets[self.index])
        }
    }
    
    private func mergeVideosAndImages(arrayData: [VideoData]) {
        DispatchQueue.global().async {
            VideoManager.shared.makeVideoFrom(data: arrayData, audioURL: self.audioUrl!, completion: {[weak self] (outputURL, error) in
                guard let `self` = self else { return }
                    DispatchQueue.main.async {
                    self.showProcessing(isShow: false)
                    if let error = error {
                        print("Error:\(error.localizedDescription)")
                    } else if let url = outputURL {
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
                                            self.openPreviewScreen(url)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            })
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

extension HomeScreenVC: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let item = mediaItemCollection.items.first else {
            print("no item")
            return
        }
        print("picking \(item.title!)")
        guard let url = item.assetURL else {
            return print("no url")
        }
        
        dismiss(animated: true) { [weak self] in
            self?.audioUrl = url
            self?.openImagePickerView()
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func startEngine(playFileAt: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            
            let avAudioFile = try AVAudioFile(forReading: playFileAt)
            let player = AVAudioPlayerNode()
            
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: avAudioFile.processingFormat)
            
            try engine.start()
            player.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
            player.play()
        } catch {
            assertionFailure(String(describing: error))
        }
    }
}
