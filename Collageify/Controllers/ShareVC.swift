import UIKit

class ShareVC: UIViewController {

    var getImage = UIImage()
    var arrAddImage = NSMutableArray()
    var objDisplay = 0
    var index = 0
    var objSetDelete = MyPhotosVC()
    
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
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        let imageToShare = [ getImage ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveAction(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(getImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        showDeleteWarning(index)
    }
    
    @IBAction func btnHomeAction(_ sender: UIButton) {
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
