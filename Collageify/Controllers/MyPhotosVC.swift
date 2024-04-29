import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds // Import Google Mobile Ads

class MyPhotosVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, GADFullScreenContentDelegate
{
   
    var arrOfAlbumList = NSArray()
    var objDelete = 0
    var bannerADsID = ""
    private var rewardAd: GADRewardedAd?
    //MARK:- Outlet
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var AlbumsCV: UICollectionView!
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!

    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("MyPhotosVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAlert.isHidden = true
        AlbumsCV.delegate = self
        AlbumsCV.dataSource = self
        AlbumsCV.register(UINib(nibName: "MainStickerCell", bundle: nil), forCellWithReuseIdentifier: "MainStickerCell")
        
        if userDefault.object(forKey: "img") != nil {
            arrOfAlbumList = (userDefault.object(forKey: "img") as! NSArray)
            AlbumsCV.reloadData()
            if arrOfAlbumList.count == 0{
                lblAlert.isHidden = false
            }else {
                lblAlert.isHidden = true
            }
        }
        if IS_ADS_SHOW == true {
        if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
            bannerView.adUnitID = adUnitID1
        }
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if arrOfAlbumList.count == 0{
            lblAlert.isHidden = false
        }else {
            lblAlert.isHidden = true
        }
    }
    //MARK:- Button Action Zone
    @IBAction func btnBackAction(_ sender: Any) {
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            showRewardAd()
            CLICK_COUNT = 0
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        }
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeScreenVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    //MARK:- Collection View Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfAlbumList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : MainStickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainStickerCell", for: indexPath) as! MainStickerCell
        if let img = arrOfAlbumList[indexPath.row] as? NSData{
            cell.imgStickers.image = UIImage(data: img as Data)
            
            if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                cell.btnStickers.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    let obj : ShareVC = self.storyboard?.instantiateViewController(withIdentifier: "ShareVC") as! ShareVC
                    obj.objDisplay = 2
                    obj.getImage = cell.imgStickers.image!
                    obj.index = indexPath.row
                    obj.objSetDelete = self
                    self.navigationController?.pushViewController(obj, animated: true)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (AlbumsCV.frame.width-20)/3
        return CGSize(width: width, height: width)
    }
}

extension MyPhotosVC {
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
