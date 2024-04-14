import UIKit
import Firebase

class InAppPurchaseVC: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthPrice.text! = "$9.99/"
        yearPrice.text! = "$19.99/"
        lifeTimePrice.text! = "$99.99"
        
        strikeThroughMonthPrice.attributedText = NSAttributedString(string: "$14.99", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        strikeThroughYearPrice.attributedText = NSAttributedString(string: "$39.99", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        strikeThroughLifeTimePrice.attributedText = NSAttributedString(string: "$199.99", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        
        setupTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        closeBtn.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.closeBtn.isHidden = false
        }
        Analytics.logEvent("purchase_screen_enter", parameters: [
            "params": "viewWillAppear"
        ])
    }
    
    private func setupTapGestureRecognizers() {
        let monthlyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedMonthlyView(_:)))
        monthlyView.addGestureRecognizer(monthlyTapGestureRecognizer)
        
        let yearlyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedYearlyView(_:)))
        yearlyView.addGestureRecognizer(yearlyTapGestureRecognizer)
        
        let lifeTimeViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedlifeTimeView(_:)))
        lifeTimeView.addGestureRecognizer(lifeTimeViewTapGestureRecognizer)
    }
    
    @IBAction func onTappedCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTappedContinueBtn(_ sender: Any) {
        // Code to handle tapping on the continue button
    }
    
    @IBAction func onTappedRestoreBtn(_ sender: Any) {
        
    }
    @IBAction func onTappedFreeTrialBtn(_ sender: Any) {
        Analytics.logEvent("freeTrial_btn_click", parameters: [
            "params": "onTappedFreeTrialBtn"
        ])
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
    }
}
