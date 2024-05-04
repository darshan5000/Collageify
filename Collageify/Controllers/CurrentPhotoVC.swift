import UIKit
import Photos
import Firebase
import SVProgressHUD
import GoogleMobileAds // Import Google Mobile Ads

class CurrentPhotoVC: UIViewController,OpalImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, GADFullScreenContentDelegate  {

    var selectedDict = [String : Int]()
    var objTotalImgSelection = 0
    var picker = OpalImagePickerController()
    var objSelectiontype = 0
    var imagePicker = UIImagePickerController()
    private var rewardAd: GADRewardedAd?
    private var interstitial: GADInterstitialAd?

    //MARK:- Outlets
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        loadRewardAd()
        loadInterstitial()
//        picker.imagePickerDelegate = self
//        picker.delegate = self
        btnDismiss.backgroundColor = UIColor.clear
        btnDismiss.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("CurrentPhotoVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
        loadRewardAd()
        loadInterstitial()
    }
    
    //MARK:- Button Action Zone
    @IBAction func btnDismissAction(_ sender: Any) {
        loadRewardAd()
        loadInterstitial()
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            TrigerInterstitial()
            CLICK_COUNT = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton) {
        loadRewardAd()
        loadInterstitial()
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            TrigerInterstitial()
            CLICK_COUNT = 0
        }
        openCamera()
    }
    
    @IBAction func btnGalleryAction(_ sender: UIButton) {
        loadRewardAd()
        loadInterstitial()
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            TrigerInterstitial()
            CLICK_COUNT = 0
        }
        openGallery()
    }
    

    
    //MARK:- UIImagePicker Delegate Methods
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if objSelectiontype == 1 {
            picker = OpalImagePickerController()
            picker.delegate = self
            picker.imagePickerDelegate = self
            picker.selectedDict = selectedDict
            picker.allowedMediaTypes = Set([PHAssetMediaType.image])
            presentOpalImagePickerController(picker, animated: true, select: { asset, allImages  in
                let requestOptions = PHImageRequestOptions()
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                requestOptions.isSynchronous = true
                var thumbnail = [UIImage]()
                let dGrrp = DispatchGroup()
                for images in asset{
                    if (images.mediaType == PHAssetMediaType.image) {
                        dGrrp.enter()
                        PHImageManager.default().requestImage(for: images , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                            thumbnail.append(pickedImage!)
                            dGrrp.leave()
                        })
                    }
                }
                dGrrp.notify(queue: .main) {
                    self.gotoNext(thumbnails: thumbnail, allImages: allImages)
                }
            }, cancel: {
            })
        } else if objSelectiontype == 2 {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func gotoNext(thumbnails: [UIImage], allImages: [[String: Any]]) {
//        picker.dismiss(animated: true) {
//            let obj = self.storyboard!.instantiateViewController(withIdentifier: "EditImageVC") as! EditImageVC
//            obj.objIndex = self.objIndex
//            obj.objPickImage = 0
//            obj.objpresentPhotoVC = self
//            obj.objType = 1
//            obj.arrOfTotalImg.append(contentsOf: thumbnails)
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
        picker.dismiss(animated: true) {
            let vc : ImageEditActionVC = self.storyboard?.instantiateViewController(withIdentifier: "EditImageStkVC") as! ImageEditActionVC
            vc.selectedDict = self.selectedDict
            vc.objType = 1
            vc.allImages = allImages
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let obj : ImageEDITViewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "EditImageVC") as! ImageEDITViewcontroller
            obj.imgValue = pickedImage
            obj.objpresentPhotoVC = self
            obj.objType = 2
            self.navigationController?.pushViewController(obj, animated: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CurrentPhotoVC {
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
        SVProgressHUD.show()
        if let rewardAd = self.rewardAd {
            SVProgressHUD.dismiss()
            rewardAd.present(fromRootViewController: self) {
            }
        } else {
            print("Ad wasn't ready")
        }
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
}
