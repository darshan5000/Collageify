import UIKit

class ALLShapeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ShapeCV: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    var curruntIndex = 0
    var lastIndex = 0
    var pickImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControll.numberOfPages = 13
        
        ShapeCV.delegate = self
        ShapeCV.dataSource = self
        ShapeCV.register(UINib(nibName: "SwipMainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SwipMainCollectionViewCell")
        ShapeCV.reloadData()
    }
    
    //MARK:- Button Action Zone
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
            self.selectedIndex(dict)
        }
        return cell
    }
    
    func selectedIndex(_ dict: [String : Int]) {
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
        
        let obj = self.storyboard!.instantiateViewController(withIdentifier: "PresentPhotoVC") as! CurrentPhotoVC
        obj.objSelectiontype = 1
        obj.selectedDict = dict
        let navController = UINavigationController(rootViewController: obj)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        self.present(navController, animated:true, completion: nil)
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
}
