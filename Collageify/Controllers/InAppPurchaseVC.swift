import UIKit
import Firebase
import GoogleMobileAds
import SVProgressHUD

class InAppPurchaseVC: UIViewController, GADFullScreenContentDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var yearlyView: UIView!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var lifeTimeView: UIView!
    
    @IBOutlet weak var strikeThroughMonthPrice: UILabel!
    @IBOutlet weak var strikeThroughYearPrice: UILabel!
    @IBOutlet weak var strikeThroughLifeTimePrice: UILabel!
    
    @IBOutlet weak var monthPrice: UILabel!
    @IBOutlet weak var yearPrice: UILabel!
    @IBOutlet weak var lifeTimePrice: UILabel!
    
    private var inAppPurchase = InAppPurchase()
    private var registeredPurchase: RegisteredPurchase = .autoRenewableForMonth
    private var rewardAd: GADRewardedAd?
    var adWasShown: Bool = false
    var rewardAdid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRewardAd()
        NotificationCenter.default.addObserver(self, selector: #selector(adWasClosed), name: Notification.Name("AdClosedNotification"), object: nil)
        monthPrice.text! = "$3.99/"
        yearPrice.text! = "$39.99/"
        lifeTimePrice.text! = "$159.00"
        
        strikeThroughMonthPrice.attributedText = NSAttributedString(string: "$7.99", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        strikeThroughYearPrice.attributedText = NSAttributedString(string: "$90.99", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        strikeThroughLifeTimePrice.attributedText = NSAttributedString(string: "$230.00", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        yearlyView.backgroundColor = .clear
        yearlyView.layer.borderWidth = 1.0
        
        lifeTimeView.backgroundColor = .clear
        lifeTimeView.layer.borderWidth = 1.0
        registeredPurchase = .autoRenewableForMonth
        setupTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("purchase_screen_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
        loadRewardAd()
    }
    
    private func setupTapGestureRecognizers() {
        let monthlyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedMonthlyView(_:)))
        monthlyView.addGestureRecognizer(monthlyTapGestureRecognizer)
        
        let yearlyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedYearlyView(_:)))
        yearlyView.addGestureRecognizer(yearlyTapGestureRecognizer)
        
        let lifeTimeViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedlifeTimeView(_:)))
        lifeTimeView.addGestureRecognizer(lifeTimeViewTapGestureRecognizer)
    }
    
    @IBAction func termOfUseBtn(_ sender: UIButton) {
        openUrl(urlString: "https://collageappprivacypolicy.blogspot.com/2024/03/terms-of-use-welcome-to-piccollagepro.html")
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        openUrl(urlString: "https://collageappprivacypolicy.blogspot.com/2024/03/privacy-policy-at-piccollagepro-we.html")
    }
    
    func openUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func onTappedCloseBtn(_ sender: Any) {
        if IS_ADS_SHOW == true {
            showAlert()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onTappedContinueBtn(_ sender: Any) {
        // Code to handle tapping on the continue button
    }
    
    @IBAction func onTappedRestoreBtn(_ sender: Any) {
        inAppPurchase.restorePurchases { restoreResults in
            if restoreResults.restoredPurchases.isEmpty && restoreResults.restoreFailedPurchases.isEmpty {
                // Show popup for no restored products and no failed purchase attempts
                self.showPopup(message: "No products found to restore.") {
                }
            } else if restoreResults.restoredPurchases.isEmpty {
                // Show popup for no restored products
                self.showPopup(message: "No products were restored.") {
                }
            } else if restoreResults.restoreFailedPurchases.isEmpty {
                // Show popup for no failed purchase attempts
                self.showPopup(message: "All products were successfully restored, but no purchase attempts failed.") {
                    self.dismiss(animated: false)
                }
            } else {
                // Handle individual failed purchase attempts
                for (error, productIdentifier) in restoreResults.restoreFailedPurchases {
                    let identifier = productIdentifier ?? "Unknown"
                    let errorMessage = "Failed to restore purchase with product identifier: \(identifier) - Error: \(error.localizedDescription)"
                    print(errorMessage) // You can log the error messages if needed
                }
            }
        }
    }
    @IBAction func onTappedFreeTrialBtn(_ sender: Any) {
        Analytics.logEvent("freeTrial_btn_click", parameters: [
            "params": "onTappedFreeTrialBtn"
        ])
        inAppPurchase.purchase(registeredPurchase, atomically: true) { isPurchased in
            isSubScription = isPurchased
            userDefault.set(isSubScription, forKey: "isSubScription")
            if isSubScription == true {
                self.dismiss(animated: true)
            }
        }
    }
    @objc func onTappedMonthlyView(_ sender: UITapGestureRecognizer) {
        // Update background color and border color for monthly view
        monthlyView.backgroundColor = UIColor(named: "selectedColor")
        monthlyView.layer.borderColor = UIColor(named: "selectedColor")?.cgColor
        monthlyView.layer.borderWidth = 1.0
        
        // Reset background color and border color for yearly view
        yearlyView.backgroundColor = .clear
        yearlyView.layer.borderWidth = 1.0
        
        lifeTimeView.backgroundColor = .clear
        lifeTimeView.layer.borderWidth = 1.0
        registeredPurchase = .autoRenewableForMonth
    }
    
    @objc func onTappedYearlyView(_ sender: UITapGestureRecognizer) {
        // Update background color and border color for yearly view
        yearlyView.backgroundColor = UIColor(named: "selectedColor")
        yearlyView.layer.borderColor = UIColor(named: "selectedColor")?.cgColor
        monthlyView.layer.borderColor = UIColor(named: "selectedColor")?.cgColor
        yearlyView.layer.borderWidth = 1.0
        
        // Reset background color and border color for monthly view
        monthlyView.backgroundColor = .clear
        monthlyView.layer.borderWidth = 1.0
        
        lifeTimeView.backgroundColor = .clear
        lifeTimeView.layer.borderWidth = 1.0
        registeredPurchase = .autoRenewableForYear
    }
    
    @objc func onTappedlifeTimeView(_ sender: UITapGestureRecognizer) {
        // Update background color and border color for monthly view
        lifeTimeView.backgroundColor = UIColor(named: "selectedColor")
        lifeTimeView.layer.borderColor = UIColor(named: "selectedColor")?.cgColor
        monthlyView.layer.borderColor = UIColor(named: "selectedColor")?.cgColor
        lifeTimeView.layer.borderWidth = 1.0
        
        // Reset background color and border color for yearly view
        monthlyView.backgroundColor = .clear
        monthlyView.layer.borderWidth = 1.0
        
        yearlyView.backgroundColor = .clear
        yearlyView.layer.borderWidth = 1.0
        registeredPurchase = .autoRenewableForLifeTime
    }
    
    func showPopup(message: String, completion: @escaping () ->Void) {
        let alertController = UIAlertController(title: "Restore Results", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        // Present the alert
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}



extension InAppPurchaseVC {
    func showAlert() {
        let alertController = UIAlertController(title: "Watch Video Ads", message: "You can continue using the FREE version by watching short video ads.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let watchNowAction = UIAlertAction(title: "Watch Now", style: .default) { (action) in
            self.showRewardAd()
        }
        alertController.addAction(watchNowAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func adWasClosed() {
        print("ADS WAS CLOSED")
        if adWasShown == true {
            dismiss(animated: true, completion: nil)
        } else {
            adWasShown = false
        }
    }
}

extension InAppPurchaseVC {
    
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
        self.dismiss(animated: true)
    }
}
