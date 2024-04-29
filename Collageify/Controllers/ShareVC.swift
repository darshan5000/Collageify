import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds // Import Google Mobile Ads

class ShareVC: UIViewController, GADFullScreenContentDelegate {

    var getImage = UIImage()
    var arrAddImage = NSMutableArray()
    var objDisplay = 0
    var index = 0
    var objSetDelete = MyPhotosVC()
    private var rewardAd: GADRewardedAd?
    
    //MARK:- Outlets
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgDisplay: UIImageView!
    @IBOutlet weak var viewButtons: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if objDisplay == 1{
            imgDisplay.image = getImage
            btnHome.frame = CGRect(x: 134, y: 14, width: 52, height: 52)
            btnSave.isHidden = true
            btnDelete.isHidden = true
        }else if objDisplay == 2{
            imgDisplay.image = getImage
            btnHome.frame = CGRect(x: 44, y: 14, width: 52, height: 52)
            btnSave.isHidden = false
            btnDelete.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("ShareVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        let imageToShare = [ getImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        UIImageWriteToSavedPhotosAlbum(getImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        showDeleteWarning(index)
    }
    
    @IBAction func btnHomeAction(_ sender: UIButton) {
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        if objDisplay == 1{
            self.navigationController?.popViewController(animated: true)
        }else if objDisplay == 2{
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeScreenVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        
    }
    
    func showDeleteWarning(_ index : Int) {
        let alert = UIAlertController(title: "Delete", message: "Did you want to Delete this Photo?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DispatchQueue.main.async {
                self.objSetDelete.objDelete = 1
                let temp = ((userDefault.object(forKey: "img")as AnyObject) as! NSArray)
                self.arrAddImage = temp.mutableCopy() as! NSMutableArray
                self.arrAddImage.removeObject(at: self.index)
                userDefault.set(self.arrAddImage, forKey: "img")
                userDefault.synchronize()
                self.navigationController?.popViewController(animated: true)
                self.objSetDelete.arrOfAlbumList = (userDefault.object(forKey: "img") as! NSArray)
                self.objSetDelete.AlbumsCV.reloadData()
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Success")
        }
    }
}

extension ShareVC {
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
}
