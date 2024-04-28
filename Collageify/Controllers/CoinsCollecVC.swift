import UIKit
import GoogleMobileAds

class CoinsCollecVC: UIViewController, GADFullScreenContentDelegate {
    
    private var registeredPurchase: RegisteredPurchase = .autoRenewableForMonth
    private var rewardAd: GADRewardedAd?
    private var timer: Timer?
    private var elapsedTime: Int = 0
    
    @IBOutlet var lblCoins: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblWatchAds: UILabel!
    @IBOutlet weak var btnWatchAds: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimer()
        loadRewardAd()
        loadCountFromUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRewardAd()
    }
    
    @IBAction func onTappedBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTappedWatchAds(_ sender: Any) {
        showRewardAd()
    }
    
    func setupTimer() {
        lblTimer.isHidden = true
        btnWatchAds.isEnabled = false
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        elapsedTime += 1
        let remainingSeconds = max(20 - elapsedTime, 0)
        
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        
        lblTimer.text = "\(minutesString):\(secondsString)"
        
        if elapsedTime >= 20 {
            timer?.invalidate()
            lblTimer.isHidden = true
            lblWatchAds.textColor = .white
            btnWatchAds.isEnabled = true
        } else {
            lblTimer.isHidden = false
            if elapsedTime % 5 == 0 {
                loadRewardAd()
            }
        }
    }
    
    func loadCountFromUserDefaults() {
        let count = UserDefaults.standard.integer(forKey: "adCount")
        lblCoins.text = "\(count)"
    }
    
    func saveCountToUserDefaults(count: Int) {
        UserDefaults.standard.set(count, forKey: "adCount")
    }
}

extension CoinsCollecVC {
    
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
                let currentCount = UserDefaults.standard.integer(forKey: "adCount")
                let newCount = currentCount + 1
                self.saveCountToUserDefaults(count: newCount)
                self.lblCoins.text = "\(newCount)"
                
                if newCount == 10 {
                    self.showAlert()
                }
            }
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Congratulations!", message: "You've collected 10 points.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        elapsedTime = 0 // Reset the elapsed time
        lblTimer.isHidden = false // Show the timer label
        lblTimer.text = "20" // Reset the timer label text to 20
        lblWatchAds.textColor = UIColor.lightGray // Set label color to light gray
        btnWatchAds.isEnabled = false // Disable the watch button
        timer?.invalidate()
        setupTimer()
    }
}
