import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds // Import Google Mobile Ads

class CurrentTextVC: UIViewController,UITextFieldDelegate, GADFullScreenContentDelegate
{
    
    var txt = ""
    var isFromEditImageStk = false
    var objImg = ImageEDITViewcontroller()
    var objImgStk = ImageEditActionVC()
    var objSelection = 0
    private var rewardAd: GADRewardedAd?
    private var interstitial: GADInterstitialAd?
    
    //MARK:- Outlet
    @IBOutlet weak var txtEdit: UITextField!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("CurrentTextVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtEdit.delegate = self
        if objSelection == 1{
            txt = txtEdit.text!
        }else if objSelection == 2 {
            if isFromEditImageStk {
                txtEdit.text = objImgStk.viewMain.currentlyEditingLabel.labelTextView?.text
            } else {
                txtEdit.text = objImg.viewMain.currentlyEditingLabel.labelTextView?.text
            }
        }else if objSelection == 3{
            txt = txtEdit.text!
        }
     }


    //MARK:- Button Action Method
    @IBAction func btnCancelAction(_ sender: Any) {
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            TrigerInterstitial()
            CLICK_COUNT = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
    func TrigerInterstitial() {
        let request = GADRequest()
        if let adUnitID1 = UserDefaults.standard.string(forKey: "INTERSTITIAL_ID") {
            GADInterstitialAd.load(withAdUnitID:adUnitID1,request: request,
                                   completionHandler: { [self] ad, error in
                if let error = error {
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
            }
            )
        }
    }
    @IBAction func btnOkAction(_ sender: Any) {
        CLICK_COUNT += 1
        print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            print("Current Ads Count >>>>>>>>>>>>>>>>>>>> \(CLICK_COUNT)")
            showRewardAd()
            CLICK_COUNT = 0
        }
        if txtEdit.text == "" {
            displayMyAlertMessage(userMessage: "Please add some text")
        }else{
            if isFromEditImageStk {
                if objSelection == 1{
                    objImgStk.addTextLabel(self.txt)
                    objImgStk.viewTextEditor.isHidden = false
                    setView(view: objImgStk.viewTextEditor)
                }else if objSelection == 2{
                    if objImgStk.viewMain.currentlyEditingLabel.labelTextView?.isSelectable == true{
                        objImgStk.viewMain.currentlyEditingLabel.labelTextView?.isUserInteractionEnabled = false
                        objImgStk.viewMain.currentlyEditingLabel.labelTextView?.text = txtEdit.text
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        objImgStk.addTextLabel(self.txt)
                    }
                }else if objSelection == 3{
                    objImgStk.addTextLabel(self.txt)
                }
            } else {
                if objSelection == 1{
                    objImg.addTextLabel(self.txt)
                    objImg.viewTextEditor.isHidden = false
                    setView(view: objImg.viewTextEditor)
                }else if objSelection == 2{
                    if objImg.viewMain.currentlyEditingLabel.labelTextView?.isSelectable == true{
                        objImg.viewMain.currentlyEditingLabel.labelTextView?.isUserInteractionEnabled = false
                        objImg.viewMain.currentlyEditingLabel.labelTextView?.text = txtEdit.text
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        objImg.addTextLabel(self.txt)
                    }
                }else if objSelection == 3{
                    objImg.addTextLabel(self.txt)
                }
            }
        }
    }
    
    //MARK:- textview delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        txtEdit.resignFirstResponder()
        self.txt = textField.text ?? ""
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text: NSString = (textField.text ?? "") as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        self.txt = resultString
        return true
    }
    
    func displayMyAlertMessage(userMessage:String){
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }

}

extension CurrentTextVC {
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
