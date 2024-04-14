import UIKit

class MyPhotosVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
   
    var arrOfAlbumList = NSArray()
    var objDelete = 0
    
    //MARK:- Outlet
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var AlbumsCV: UICollectionView!
    @IBOutlet weak var lblAlert: UILabel!
    
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
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeScreenVC.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
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
