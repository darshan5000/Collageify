import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds // Import Google Mobile Ads

class StickersVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, GADFullScreenContentDelegate{
    
    //MARK:- outlet
    @IBOutlet weak var SelectStickersCV: UICollectionView!
    @IBOutlet weak var StickersCV: UICollectionView!
    
    var objStickers = 0
    var isFromEditImageStk = false
    var objImage = ImageEDITViewcontroller()
    var objImageStk = ImageEditActionVC()
    private var rewardAd: GADRewardedAd?
    var objStickerSelecion = 0
    var img = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRewardAd()
        SelectStickersCV.delegate = self
        SelectStickersCV.dataSource = self
        SelectStickersCV.register(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
        SelectStickersCV.reloadData()
        
        StickersCV.delegate = self
        StickersCV.dataSource = self
        StickersCV.register(UINib(nibName: "MainStickerCell", bundle: nil), forCellWithReuseIdentifier: "MainStickerCell")
        StickersCV.reloadData()
        objStickers = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("StickersVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
        loadRewardAd()
    }
    
    //MARK:- Action Button Zone
    @IBAction func btnBackAction(_ sender: Any) {
        if IS_ADS_SHOW == true {
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.SelectStickersCV{
            return arrOfStickersItems.count
        }else if collectionView == self.StickersCV{
            if objStickers == 1{
                return 49
            }else if objStickers == 2{
                return 22
            }else if objStickers == 3{
                return 64
            }else if objStickers == 4{
                return 151
            }else if objStickers == 5{
                return 23
            }else if objStickers == 6{
                return 27
            }else if objStickers == 7{
                return 60
            }else if objStickers == 8{
                return 100
            }else if objStickers == 9{
                return 60
            }
            return 0
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.SelectStickersCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
            if cell.btnImage == (cell.viewWithTag(5) as? UIButton) {
                cell.imgSelection.image = UIImage(named: arrOfStickersItems[indexPath.row])
                cell.btnImage.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.StickersCV.reloadData()
                    if indexPath.row == 0 {
                        self.objStickers = 1
                    }else if indexPath.row == 1{
                        self.objStickers = 2
                    }else if indexPath.row == 2{
                        self.objStickers = 3
                    }else if indexPath.row == 3{
                        self.objStickers = 4
                    }else if indexPath.row == 4{
                        self.objStickers = 5
                    }else if indexPath.row == 5{
                        self.objStickers = 6
                    }else if indexPath.row == 6{
                        self.objStickers = 7
                    }else if indexPath.row == 7{
                        self.objStickers = 8
                    } else if indexPath.row == 8{
                        self.objStickers = 9
                    }
                }
            }
            return cell
        }else if collectionView == self.StickersCV{
            let cell: MainStickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainStickerCell", for: indexPath) as! MainStickerCell
            if self.objStickers == 1{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "new_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "new_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else if self.objStickers == 2{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "couple_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "couple_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }  else if self.objStickers == 3{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "feather_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "feather_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 4{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "text_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "text_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 5{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "heart_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "heart_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 6{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "Buterfly_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "Buterfly_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 7{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "Bubbles_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "Bubbles_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 8{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "Cools_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "Cools_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if self.objStickers == 9{
                if cell.btnStickers == (cell.viewWithTag(25) as? UIButton) {
                    cell.imgStickers.image = UIImage(named: "other_\(indexPath.row+1)")
                    cell.btnStickers.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == arrOfIndex[indexPath.row]{
                            self.img = UIImage(named: "other_\(indexPath.row+1)")!
                            if self.isFromEditImageStk {
                                self.objImageStk.setStickers(self.img)
                            } else {
                                self.objImage.setStickers(self.img)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.SelectStickersCV{
            return CGSize(width: 60, height: 60)
        }else if collectionView == StickersCV{
            let width  = (StickersCV.frame.width-20)/3
            return CGSize(width: width, height: width)
            
        };return CGSize()
    }
}

extension StickersVC {
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
