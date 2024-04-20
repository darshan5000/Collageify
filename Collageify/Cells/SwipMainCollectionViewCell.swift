import UIKit
import Firebase

class SwipMainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var swipeCV: UICollectionView!
    
    var framesJson = [[String : Int]]()
    var selectedImage : (([String : Int]) -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        swipeCV.delegate = self
        swipeCV.dataSource = self
        swipeCV.register(UINib(nibName: "allFramesCell", bundle: nil), forCellWithReuseIdentifier: "allFramesCell")
        swipeCV.reloadData()
    }
}

extension SwipMainCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK:- CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return framesJson.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : allFramesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "allFramesCell", for: indexPath) as! allFramesCell
        let dict = framesJson[indexPath.item]
        cell.imgFrame.image = UIImage(named: "\(dict["image"] ?? 0)")
        cell.lblIndex.text = ""//"\(dict["image"] ?? 0)"
        if (dict["isPremium"] ?? 0) == 1 {
            cell.imgFrame.tintColor = UIColor(red: 77.0/255.0, green: 171.0/255.0, blue: 252.0/255.0, alpha: 1.0)
            cell.viewBG.backgroundColor = UIColor(red: 77.0/255.0, green: 171.0/255.0, blue: 252.0/255.0, alpha: 0.1)
        } else {
            cell.imgFrame.tintColor = .white
            cell.viewBG.backgroundColor = .clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = framesJson[indexPath.item]
        selectedImage?(dict)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        let width  = (collectionView.frame.width)/4
        let height  = (collectionView.frame.height)/6
        return CGSize(width: width, height: height)
    }
}
