import UIKit
import GoogleMobileAds // Import Google Mobile Ads
import SVProgressHUD

class ALLShapeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, GADFullScreenContentDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ShapeCV: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var curruntIndex = 0
    var lastIndex = 0
    var pickImg = UIImage()
    private var rewardAd: GADRewardedAd?
    var frameDict: [String : Int]?
    
    override func viewWillAppear(_ animated: Bool) {
        loadRewardAd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControll.numberOfPages = 13
        
        ShapeCV.delegate = self
        ShapeCV.dataSource = self
        ShapeCV.register(UINib(nibName: "SwipMainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SwipMainCollectionViewCell")
        ShapeCV.reloadData()
        if IS_ADS_SHOW == true {
            if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID1
            }
            
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    // MARK: - GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SwipMainCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwipMainCollectionViewCell", for: indexPath) as! SwipMainCollectionViewCell
        cell.framesJson = allHomeScreenFramesJson["\(indexPath.item + 1)"] ?? []
        cell.swipeCV.reloadData()
        cell.selectedImage = { dict in
            print(dict)
            self.frameDict = dict
            self.selectedIndex(dict)
        }
        return cell
    }
    
    func selectedIndex(_ dict: [String : Int]) {
        if (dict["isPremium"] ?? 0) == 1 {
            print("PRIMIUM_FRAME")
            if IS_ADS_SHOW == true {
                showAlert()
                
            } else {
                //        let vc : EditImageStkVC = self.storyboard?.instantiateViewController(withIdentifier: "EditImageStkVC") as! EditImageStkVC
                //        let parts = dict["parts"] ?? 0
                //        var allImages = [[String : Any]]()
                //        for _ in 0..<parts {
                //            let dict = ["image" : UIImage(), "index": IndexPath()] as [String : Any]
                //            allImages.append(dict)
                //        }
                //        vc.selectedDict = dict
                //        vc.allImages = allImages
                //        vc.objType = 1
                //        self.navigationController?.pushViewController(vc, animated: true)
                
                let obj = self.storyboard!.instantiateViewController(withIdentifier: "CurrentPhotoVC") as! CurrentPhotoVC
                obj.objSelectiontype = 1
                obj.selectedDict = dict
                let navController = UINavigationController(rootViewController: obj)
                navController.navigationBar.isHidden = true
                navController.modalPresentationStyle = .overCurrentContext
                self.present(navController, animated:true, completion: nil)
            }
        } else {
            let obj = self.storyboard!.instantiateViewController(withIdentifier: "CurrentPhotoVC") as! CurrentPhotoVC
            obj.objSelectiontype = 1
            obj.selectedDict = dict
            let navController = UINavigationController(rootViewController: obj)
            navController.navigationBar.isHidden = true
            navController.modalPresentationStyle = .overCurrentContext
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
                        IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: ShapeCV.contentOffset, size: ShapeCV.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = ShapeCV.indexPathForItem(at: visiblePoint)
        pageControll.currentPage = (visibleIndexPath?.row ?? 0)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Premium Features !!", message: "Access Premium content by opting into our ad-supported model", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let watchNowAction = UIAlertAction(title: "Watch Now", style: .default) { (action) in
            self.showRewardAd()
        }
        alertController.addAction(watchNowAction)
        present(alertController, animated: true, completion: nil)
    }
}


extension ALLShapeVC {
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
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("NAVIGATE_KARO")
        let obj = self.storyboard!.instantiateViewController(withIdentifier: "CurrentPhotoVC") as! CurrentPhotoVC
        obj.objSelectiontype = 1
        obj.selectedDict = frameDict ?? [:]
        let navController = UINavigationController(rootViewController: obj)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        self.present(navController, animated:true, completion: nil)
        
    }
}
