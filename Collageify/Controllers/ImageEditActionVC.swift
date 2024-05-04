
import Foundation
import ZoomImageView
import CoreGraphics
import IGColorPicker
import ImageScrollView
import SVProgressHUD
import Firebase
import GoogleMobileAds

enum ShapeType {
    case point(CGPoint, [CGFloat])
    case angle(CGFloat, [Int], CGFloat, [CGPoint], [CGFloat])//degree,comparepoint,radius,linescross,pad
}

enum CurveDirection {
    case top
    case bottom
    case left
    case right
}

enum ViewType {
    case hstack
    case vstack
    case view
}

enum ViewSize {
    case height(CGFloat)
    case width(CGFloat)
}

struct ViewStyle {
    var type: ViewType = .view
    var ratio = ViewSize.height(1)
    var tag = -1
    var subViews = [ViewStyle]()
}


class ImageEditActionVC: UIViewController,GADFullScreenContentDelegate, GADBannerViewDelegate  {
    
    private var padding: CGFloat = 3
    private let cornerRadius: CGFloat = 10
    var selectedDict = [String : Int]()
    var objPickIndex = 0
    var objType = 0
    var allImages = [[String: Any]]()
    var imgFilter = UIImage()
    var objpresentPhotoVC = CurrentPhotoVC()
    var imgValue = UIImage()
    var isSelectGallery = false
    var objSelectTxtValue = 0
    private var interstitial: GADInterstitialAd?
    var isImageEmpty = false
    var imgIndex = 0
    var imagePicker = UIImagePickerController()
    
    //MARK:- Outlets
    @IBOutlet weak var lblMainTitle: UILabel!
    @IBOutlet weak var viewMain: JLStickerImageView!
    @IBOutlet weak var viewGridMain: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgTexture: UIImageView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var ShapeCV: UICollectionView!
    @IBOutlet weak var BackGroundCV: UICollectionView!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var FxCV: UICollectionView!
    
    @IBOutlet weak var viewMainItems: UIView!
    @IBOutlet weak var mainItemsCV: UICollectionView!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var viewShapes: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDown: UIButton!
    
    @IBOutlet weak var btnKeyboard: UIButton!
    @IBOutlet weak var btnFontStyle: UIButton!
    @IBOutlet weak var btnColor: UIButton!
    @IBOutlet weak var btnAlign: UIButton!
    @IBOutlet weak var btnAddText: UIButton!
    @IBOutlet weak var btnDown1: UIButton!
    
    @IBOutlet weak var viewTextEditor: UIView!
    @IBOutlet weak var viewTextStyle: UIView!
    @IBOutlet weak var tblFontStyle: UITableView!
    
    @IBOutlet weak var viewAlign: UIView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnCenter: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var viewColorPicker: UIView!
    @IBOutlet weak var sliderOpacity: UISlider!
    
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBOutlet weak var viewReplaceImg: UIView!
    @IBOutlet weak var btnReplace: UIButton!
    @IBOutlet weak var btnFlipV: UIButton!
    @IBOutlet weak var btnFlipH: UIButton!
    @IBOutlet weak var btnDown3: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    
    private var _selectedStickerView:StickerView?
    
    var selectedStickerView:StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditing = false
                }
                _selectedStickerView = newValue
            }
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditing = true
                selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
            }
        }
    }
    
    var points = [[CGPoint]]()
    
    let s: CGFloat = 1
    let s0: CGFloat = 0
    let s1: CGFloat = 1/1.5
    let s2: CGFloat = 1/2
    let s3: CGFloat = 1/3
    let s4: CGFloat = 1/4
    let s5: CGFloat = 1/4.7
    let s6: CGFloat = 1/1.27
    var rect = CGRect()
    
    override func viewWillAppear(_ animated: Bool) {
//        loadInterstitial()
        TrigerInterstitial()
        Analytics.logEvent("ImageEditActionVC_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterstitial()
        if IS_ADS_SHOW == true {
            if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID1
            }
            
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
        rect = viewGridMain.bounds
        
        let index = selectedDict["image"] ?? 0
        DispatchQueue.main.async {
            self.viewBasedOnIndex(ix: index - 1)
        }
        
        imagePicker.delegate = self
        
        viewShapes.isHidden = true
        viewTextEditor.isHidden = true
        viewAlign.isHidden = true
        viewColorPicker.isHidden = true
        
        for item in viewShapes.subviews {
            if item is UICollectionView {
                let collection: UICollectionView = item as! UICollectionView
                collection.isHidden = true
            }
        }
        
        mainItemsCV.delegate = self
        mainItemsCV.dataSource = self
        mainItemsCV.register(UINib(nibName: "SelectItemCell", bundle: nil), forCellWithReuseIdentifier: "SelectItemCell")
        mainItemsCV.reloadData()
        
        ShapeCV.delegate = self
        ShapeCV.dataSource = self
        ShapeCV.register(UINib(nibName: "StickerCell", bundle: nil), forCellWithReuseIdentifier: "StickerCell")
        ShapeCV.reloadData()
        
        BackGroundCV.delegate = self
        BackGroundCV.dataSource = self
        BackGroundCV.register(UINib(nibName: "FramesCell", bundle: nil), forCellWithReuseIdentifier: "FramesCell")
        BackGroundCV.reloadData()
        
        FilterCV.delegate = self
        FilterCV.dataSource = self
        FilterCV.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        FilterCV.reloadData()
        
        FxCV.delegate = self
        FxCV.dataSource = self
        FxCV.register(UINib(nibName: "FramesCell", bundle: nil), forCellWithReuseIdentifier: "FramesCell")
        FxCV.reloadData()
        
        tblFontStyle.delegate = self
        tblFontStyle.dataSource = self
        tblFontStyle.register(UINib(nibName: "tblStyleCell", bundle: nil), forCellReuseIdentifier: "tblStyleCell")
        tblFontStyle.reloadData()
        
        viewReplaceImg.isHidden = true
        viewMain.isFromEditImageStk = true
        viewMain.objselectionStk = self
        
        if objType == 1 {
            lblMainTitle.text = "GRID"
            //            setframe(objIndex)
        } else if objType == 2 {
            lblMainTitle.text = "EDIT"
            //            setSingleFrame()
        }
    }
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewBasedOnIndex(ix: Int) {
        switch ix {
        case 0:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/1), tag: 0),
            ])
            break
        case 1:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
            ])
            break
        case 2:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
            ])
            break
        case 3:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
            ])
            break
        case 4:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
            ])
            break
        case 5:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
            ])
            break
        case 6:
            let s: CGFloat = 1/2
            createViewWithMaskCurve(list: [(dir: .top, shapes: [[0,0,1,1], [1,0,-1,1], [1,s,-1,-1], [0,s,1,-1]]),
                                           (dir: .bottom, shapes: [[0,1,1,-1], [1,1,-1,-1], [1,s,-1,1], [0,s,1,1]])])
            break
        case 7:
            let s: CGFloat = 1/2
            createViewWithMaskCurve(list: [(dir: .left, shapes: [[0,1,1,-1], [0,0,1,1], [s,0,-1,1], [s,1,-1,-1]]),
                                           (dir: .right, shapes: [[1,1,-1,-1], [1,0,-1,1], [s,0,1,1], [s,1,1,-1]])])
            break
        case 8:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 3),
                ]),
            ])
            break
        case 9:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 3),
                ]),
            ])
            break
        case 10:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
            ])
            break
        case 11:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
            ])
            break
        case 12:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ]),
            ])
            break
        case 13:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
            ])
            break
        case 14:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ]),
            ])
            break
        case 15:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
            ])
            break
        case 16:
            
            let s44: CGFloat = 1/4
            let s45: CGFloat = (1-s44)
            let s54: CGFloat = 1/2.6
            let s55: CGFloat = (1-s54)
            
            createShape(index: 0, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .angle(100, [0,1], -1, [[s54,s].toPoint(rect: rect), [s55,s0].toPoint(rect: rect)], [1,1]),
                .point([s54,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s0, s44].toPoint(rect: rect), [1,1]),
                .angle(82, [1,1], -1, [[s54,s].toPoint(rect: rect), [s55,s0].toPoint(rect: rect)], [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point(.zero, [1,1]),
                .point([s55,s0].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .angle(100, [3,1], -1, [[s,s0].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .angle(82, [4,1], -1, [[s,s0].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [1,1]),
                .point(points[3][2], [1,1]),
            ])
            createShape(index: 5, ptArr: [
                .point(points[2][3], [1,1]),
                .point(points[2][2], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[4][2], [1,1]),
            ])
            break
        case 17:
            let s44: CGFloat = 1/4
            let s45: CGFloat = (1-s44)
            let s54: CGFloat = 1/2.6
            let s55: CGFloat = (1-s54)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .angle(10, [0,1], -1, [[s0,s54].toPoint(rect: rect), [s,s55].toPoint(rect: rect)], [1,1]),
                .point([s0,s54].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .angle(352, [1,1], -1, [[s0,s54].toPoint(rect: rect), [s,s55].toPoint(rect: rect)], [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s55].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .angle(10, [3,1], -1, [[s0,s].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .angle(352, [4,1], -1, [[s0,s].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [1,1]),
                .point(points[3][2], [1,1]),
            ])
            createShape(index: 5, ptArr: [
                .point(points[2][3], [1,1]),
                .point(points[2][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[4][2], [1,1]),
            ])
            break
        case 20:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s5,s0].toPoint(rect: rect), [-1,1]),
                .angle(30, [0,1], rect.width/3, [], [-1,-1]),
                .angle(300, [0,2], -1, [.zero, [s0,s].toPoint(rect: rect)], [1,-1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [-1,1]),
                .angle(30, [0,2], -1, [[s,s].toPoint(rect: rect), [s0,s].toPoint(rect: rect)], [-1,-1]),
                .point([s0,s].toPoint(rect: rect), [1,-1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [-1,1]),
                .point(CGPoint(x: rect.width, y: rect.width-points[0][3].y), [-1,-1]),
                .angle(300, [2,2], -1, [points[1][1], points[1][2]], [1,-1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[2][3], [1,1]),
                .point(points[2][2], [-1,1]),
                .point([s,s].toPoint(rect: rect), [-1,-1]),
                .point(points[1][2], [1,-1]),
            ])
            break
        case 21:
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s6,s0].toPoint(rect: rect), [-1,1]),
                .angle(330, [0,1], rect.width/3, [], [-1,-1]),
                .angle(60, [0,2], -1, [[s,s].toPoint(rect: rect), [s,s0].toPoint(rect: rect)], [1,-1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [-1,1]),
                .angle(330, [0,2], -1, [[s,s].toPoint(rect: rect), [s0,s].toPoint(rect: rect)], [-1,-1]),
                .point([s,s].toPoint(rect: rect), [1,-1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s0,s0].toPoint(rect: rect), [-1,1]),
                .point(CGPoint(x: 0, y: rect.width-points[0][3].y), [-1,-1]),
                .angle(60, [2,2], -1, [points[1][1], points[1][2]], [1,-1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[2][3], [1,1]),
                .point(points[2][2], [-1,1]),
                .point([s0,s].toPoint(rect: rect), [-1,-1]),
                .point(points[1][2], [1,-1]),
            ])
            break
        case 22:
            let s44: CGFloat = 1/5
            let s45: CGFloat = (1-s44)
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s0].toPoint(rect: rect), [-1,1]),
                .point([s2,s44].toPoint(rect: rect), [-1,1]),
                .point([s44,s2].toPoint(rect: rect), [-1,1]),
                .point([s0,s2].toPoint(rect: rect), [-1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [-1,1]),
                .point([s,s2].toPoint(rect: rect), [-1,1]),
                .point([s45,s2].toPoint(rect: rect), [-1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [-1,1]),
                .point([s2,s].toPoint(rect: rect), [-1,1]),
                .point([s2,s45].toPoint(rect: rect), [-1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[2][4], [1,1]),
                .point(points[2][3], [1,1]),
                .point([s0,s].toPoint(rect: rect), [-1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[2][0], [1,1]),
                .point(points[2][4], [1,1]),
            ])
            break
        case 23:
            let s44: CGFloat = 1/4.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point([s44,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s44].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s45].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .angle(135, [0,0], -1, [.zero, [s,s0].toPoint(rect: rect)], [-1,-1]),
                .point(points[0][0], [1,1]),
                .angle(225, [0,0], -1, [.zero, [s0,s].toPoint(rect: rect)], [-1,-1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(CGPoint(x: rect.width, y: points[1][1].x), [1,1]),
                .point(points[0][1], [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[2][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(CGPoint(x: rect.width-points[1][1].x, y: rect.width), [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[3][3], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 24:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 25:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 26:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 27:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 28:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 29:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 30:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .angle(280, [0,2], -1, [.zero, [s0,s].toPoint(rect: rect)], [-1,-1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .angle(10, [1,1], -1, [[s,s].toPoint(rect: rect), [s0,s].toPoint(rect: rect)], [-1,-1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1])
            ])
            break
        case 31:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .angle(100, [0,0], -1, [[s,s].toPoint(rect: rect), [s,s0].toPoint(rect: rect)], [-1,-1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .point(.zero, [1,1]),
                .angle(190, [1,0], -1, [.zero, [s,s0].toPoint(rect: rect)], [-1,-1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][3], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1]),
                .point(points[1][0], [1,1])
            ])
            break
        case 32:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point(points[1][1], [1,1]),
                .point(points[0][2], [1,1])
            ])
            break
        case 33:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][0], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
            ])
            break
        case 34:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
            ])
            break
        case 35:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
            ])
            break
        case 36:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .angle(190, [0,2], -1, [.zero, [s,s0].toPoint(rect: rect)], [-1,-1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][3], [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .angle(280, [1,2], -1, [.zero, [s0,s].toPoint(rect: rect)], [-1,-1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 37:
            let s44: CGFloat = 1/2.4
            let s45: CGFloat = (1-s44)
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .angle(10, [0,1], -1, [[s0,s].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [-1,-1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .angle(100, [1,0], -1, [[s,s0].toPoint(rect: rect), [s,s].toPoint(rect: rect)], [-1,-1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][0], [  1,1]),
                .point(points[1][3], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 38:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [  1,1]),
                .point(points[1][1], [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 39:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point(points[1][1], [1,1]),
                .point(points[0][1], [1,1]),
            ])
            break
        case 40:
            let s44: CGFloat = 1/4
            let s45: CGFloat = 1/2.8
            let s444: CGFloat = s44 + 1/3
            let s455: CGFloat = s45 + 1/3
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s2,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s444].toPoint(rect: rect), [1,1]),
                .point([s2,s455].toPoint(rect: rect), [1,1]),
                .point([s0,s444].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][5], [1,1]),
                .point(points[1][4], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 41:
            let s44: CGFloat = 1 - 1/4
            let s45: CGFloat = 1 - 1/2.8
            let s444: CGFloat = s44 - 1/3
            let s455: CGFloat = s45 - 1/3
            
            createShape(index: 0, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s2,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s444].toPoint(rect: rect), [1,1]),
                .point([s2,s455].toPoint(rect: rect), [1,1]),
                .point([s0,s444].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][5], [1,1]),
                .point(points[1][4], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(.zero, [1,1]),
            ])
            break
        case 42:
            let s44: CGFloat = 2/3
            let s45: CGFloat = 1 - s44
            let s54: CGFloat = 2/3
            let s55: CGFloat = 1 - s54
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s44,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[2][3], [1,1]),
            ])
            break
        case 43:
            let s44: CGFloat = 2/3
            let s45: CGFloat = 1 - s44
            let s54: CGFloat = 2/3
            let s55: CGFloat = 1 - s54
            
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s45].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point(.zero, [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
                .point([s45,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[2][3], [1,1]),
            ])
            break
        case 44:
            let s44: CGFloat = 1/5
            let s45: CGFloat = (1-s44)
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point([s44,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s44].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s45].toPoint(rect: rect), [1,1])
            ])
            break
        case 46:
            
            break
        case 47:
            
            break
        case 48:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
            ])
            break
        case 49:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
            ])
            break
        case 50:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
            ])
            break
        case 51:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
            ])
            break
        case 52:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                ]),
            ])
            break
        case 53:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
            ])
            break
        case 54:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
            ])
            break
        case 55:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
            ])
            break
        case 56:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
            ])
            break
        case 57:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
            ])
            break
        case 58:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
            ])
            break
        case 59:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
            ])
            break
        case 60:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                ]),
            ])
            break
        case 61:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
            ])
            break
        case 62:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 3),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                ]),
            ])
            break
        case 63:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 5),
                ]),
            ])
            break
        case 64:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1]),
            ])
            break
        case 65:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1]),
            ])
            break
        case 66:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[1][3], [1,1]),
            ])
            break
        case 67:
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point(.zero, [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[1][3], [1,1]),
            ])
            break
        case 68:
            let s44: CGFloat = 1/4
            let s45: CGFloat = 1/2.8
            let s444: CGFloat = s44 + 1/3
            let s455: CGFloat = s45 + 1/3
            
            createShape(index: 0, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s444,s0].toPoint(rect: rect), [1,1]),
                .point([s455,s2].toPoint(rect: rect), [1,1]),
                .point([s444,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][5], [1,1]),
                .point(points[1][4], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 69:
            let s44: CGFloat = 1 - 1/3.8
            let s45: CGFloat = 1 - 1/2.8
            let s444: CGFloat = s44 - 1/3
            let s455: CGFloat = s45 - 1/3
            
            createShape(index: 0, ptArr: [
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s444,s0].toPoint(rect: rect), [1,1]),
                .point([s455,s2].toPoint(rect: rect), [1,1]),
                .point([s444,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][5], [1,1]),
                .point(points[1][4], [1,1]),
                .point(points[1][3], [1,1]),
                .point(.zero, [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 70:
            let s44: CGFloat = 1/3
            let s45: CGFloat = 1 - s44
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s44,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point(points[0][3], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][1], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 71:
            let s44: CGFloat = 1/3
            let s45: CGFloat = 1 - s44
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s44].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s2,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 72:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                ]),
            ])
            break
        case 73:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
            ])
            break
        case 74:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ]),
                ]),
            ])
            break
        case 75:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
            ])
            break
        case 76:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
            ])
            break
        case 77:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
            ])
            break
        case 78:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
            ])
            break
        case 79:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
            ])
            break
        case 80:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                ]),
            ])
            break
        case 81:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
            ])
            break
        case 82:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
            ])
            break
        case 83:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
            ])
            break
        case 84:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
            ])
            break
        case 85:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                ]),
            ])
            break
        case 86:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
            ])
            break
        case 87:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
            ])
            break
        case 88:
            let s44: CGFloat = 1/2
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s44].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 89:
            let s44: CGFloat = 1/2
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][1], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[0][3], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[1][3], [1,1]),
            ])
            break
        case 90:
            let s44: CGFloat = 1/2
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 91:
            let s44: CGFloat = 1/2
            createShape(index: 0, ptArr: [
                .point([s0,s2].toPoint(rect: rect), [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][1], [1,1]),
                .point(points[0][0], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][0], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 92:
            let s44: CGFloat = 2/3
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
                .point([s44,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][3], [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[2][3], [1,1]),
            ])
            break
        case 93:
            let s44: CGFloat = 2/3
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s45].toPoint(rect: rect), [1,1]),
                .point([s45,s44].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][4], [1,1]),
                .point(points[0][3], [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[2][2], [1,1]),
            ])
            break
        case 94:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 95:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 96:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
            ])
            break
        case 97:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
            ])
            break
        case 98:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
            ])
            break
        case 99:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
            ])
            break
        case 100:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
            ])
            break
        case 101:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 102:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
            ])
            break
        case 103:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
            ])
            break
        case 104:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 105:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 106:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
            ])
            break
        case 107:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                ]),
            ])
            break
        case 108:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 109:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                ]),
            ])
            break
        case 110:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 111:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                ]),
            ])
            break
        case 112:
            createShape(index: 0, ptArr: [
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1]),
                .point(points[0][0], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][0], [1,1]),
                .point(points[1][3], [1,1]),
                .point(points[0][3], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 113:
            createShape(index: 0, ptArr: [
                .point([s0,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][1], [1,1]),
                .point(points[0][0], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
                .point(points[0][1], [1,1]),
            ])
            break
        case 114:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(.zero, [1,1]),
                .point(points[1][2], [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(.zero, [1,1]),
                .point(points[2][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 115:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[1][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(points[2][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 116:
            let s44: CGFloat = 1/1.7
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s2].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][3], [1,1]),
            ])
            break
        case 117:
            let s44: CGFloat = 1/1.7
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s2].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point(.zero, [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[0][3], [1,1]),
            ])
            break
        case 118:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s2].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 3, ptArr: [
                .point(.zero, [1,1]),
                .point(points[2][3], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1])
            ])
            break
        case 119:
            createShape(index: 0, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point([s2,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][0], [1,1]),
                .point(.zero, [1,1]),
                .point(points[0][1], [1,1])
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1])
            ])
            break
        case 120:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                ]),
            ])
            break
        case 121:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
            ])
            break
        case 122:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                ]),
            ])
            break
        case 123:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 124:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
            ])
            break
        case 125:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
            ])
            break
        case 126:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
            ])
            break
        case 127:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
            ])
            break
        case 128:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 5),
                ]),
            ])
            break
        case 129:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                ]),
            ])
            break
        case 130:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3)),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
            ])
            break
        case 131:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
            ])
            break
        case 132:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                ]),
            ])
            break
        case 133:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
            ])
            break
        case 134:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
            ])
            break
        case 135:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
            ])
            break
        case 136:
            let s44: CGFloat = 1/1.7
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[2][2], [1,1]),
            ])
            break
        case 137:
            let s44: CGFloat = 1 - 1/1.7
            let s45: CGFloat = 1/1.7
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1])
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[1][2], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[2][2], [1,1]),
            ])
            break
        case 138:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index:1, ptArr: [
                .point(.zero, [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index:3, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s2].toPoint(rect: rect), [1,1]),
            ])
            break
        case 139:
            let s44: CGFloat = 1/4
            let s45: CGFloat = 1 - s44
            let s54: CGFloat = 1/3
            let s55: CGFloat = 1 - s54
            
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s54,s54].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s55,s54].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point([s55,s55].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .point([s54,s55].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[0][1], [1,1]),
                .point(points[1][0], [1,1]),
                .point(points[1][3], [1,1]),
                .point(points[1][2], [1,1]),
                .point(points[2][1], [1,1]),
                .point(points[2][0], [1,1]),
                .point(points[2][3], [1,1]),
                .point(points[3][2], [1,1]),
                .point(points[3][1], [1,1]),
                .point(points[3][0], [1,1]),
                .point(points[0][3], [1,1]),
                .point(points[0][2], [1,1]),
            ])
            break
        case 140:
            let s44: CGFloat = 1/3.7
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][0], [1,1]),
                .point(points[0][7], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][3], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][4], [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[0][5], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[0][6], [1,1]),
            ])
            break
        case 141:
            let s44: CGFloat = 1/2
            let s45: CGFloat = 1 - s44
            createShape(index: 0, ptArr: [
                .point([s44,s0].toPoint(rect: rect), [1,1]),
                .point([s45,s0].toPoint(rect: rect), [1,1]),
                .point([s,s44].toPoint(rect: rect), [1,1]),
                .point([s,s45].toPoint(rect: rect), [1,1]),
                .point([s45,s].toPoint(rect: rect), [1,1]),
                .point([s44,s].toPoint(rect: rect), [1,1]),
                .point([s0,s45].toPoint(rect: rect), [1,1]),
                .point([s0,s44].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point(points[0][0], [1,1]),
                .point(points[0][7], [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point(points[0][2], [1,1]),
            ])
            createShape(index: 3, ptArr: [
                .point(points[0][3], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point(points[0][4], [1,1]),
            ])
            createShape(index: 4, ptArr: [
                .point(points[0][5], [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
                .point(points[0][6], [1,1]),
            ])
            break
        case 142:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(.zero, [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 143:
            createShape(index: 0, ptArr: [
                .point(.zero, [1,1]),
                .point([s,s0].toPoint(rect: rect), [1,1]),
                .point([s0,s2].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 1, ptArr: [
                .point(points[0][2], [1,1]),
                .point(points[0][1], [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
                .point([s0,s].toPoint(rect: rect), [1,1]),
            ])
            createShape(index: 2, ptArr: [
                .point(points[0][1], [1,1]),
                .point([s,s].toPoint(rect: rect), [1,1]),
                .point([s2,s].toPoint(rect: rect), [1,1]),
            ])
            break
        case 144:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
            ])
            break
        case 145:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
            ])
            break
        case 146:
            
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ]),
                ]),
            ])
            break
        case 147:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                ]),
            ])
            break
        case 148:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(2/5), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.height(2/5), tag: 6),
            ])
            break
        case 149:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(2/5), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.width(2/5), tag: 6),
            ])
            break
        case 150:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 3),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
            ])
            break
        case 151:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 3),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
            ])
            break
        case 152:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/7), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
            ])
            break
        case 153:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.width(1/7), tag: 6),
            ])
            break
        case 154:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
            ])
            break
        case 155:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
            ])
            break
        case 156:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 6),
                ]),
            ])
            break
        case 157:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
            ])
            break
        case 158:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 2),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 159:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 2),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
            ])
            break
        case 168:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
            ])
            break
        case 169:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
            ])
            break
        case 170:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
            ])
            break
        case 171:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ]),
                ]),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
            ])
            break
        case 172:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ]),
                ]),
            ])
            break
        case 173:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                ]),
            ])
            break
        case 174:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                ViewStyle(ratio: ViewSize.width(3/5), tag: 1),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 6),
                ]),
            ])
            break
        case 175:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.width(3/5), tag: 5),
                ViewStyle(ratio: ViewSize.width(1/5), tag: 6),
            ])
            break
        case 176:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
            ])
            break
        case 177:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ]),
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
            ])
            break
        case 178:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
            ])
            break
        case 179:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
            ])
            break
        case 180:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
            ])
            break
        case 181:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
            ])
            break
        case 182:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 183:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 186:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(ratio: ViewSize.height(2/4), tag: 1),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
            ])
            break
        case 192:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
            ])
            break
        case 193:
            break
        case 195:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/3), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
            ])
            break
        case 196:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
            ])
            break
        case 197:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
            ])
            break
        case 198:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                ViewStyle(ratio: ViewSize.height(3/5), tag: 1),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 6),
                ]),
            ])
            break
        case 199:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.height(3/5), tag: 5),
                ViewStyle(ratio: ViewSize.height(1/5), tag: 6),
            ])
            break
        case 200:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.height(1/7), tag: 6),
            ])
            break
        case 201:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/7), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
            ])
            break
        case 202:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 4),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ]),
                ]),
            ])
            break
        case 203:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ]),
                    ViewStyle(ratio: ViewSize.width(3/4), tag: 7),
                ]),
            ])
            break
        case 204:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
            ])
            break
        case 205:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
            ])
            break
        case 206:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.height(2/4), tag: 4),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                ]),
            ])
            break
        case 207:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(ratio: ViewSize.width(2/4), tag: 4),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                ]),
            ])
            break
        case 208:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 3),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                ]),
            ])
            break
        case 209:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(5/7), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                ]),
            ])
        case 216:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 5),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 217:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 5),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 218:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                ]),
            ])
            break
        case 219:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 11),
                ]),
            ])
            break
        case 220:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ]),
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ]),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                        ]),
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                        ]),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                ]),
            ])
            break
        case 221:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ]),
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ]),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                        ]),
                        ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                            ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                        ]),
                    ]),
                ]),
            ])
            break
        case 222:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                ]),
            ])
            break
        case 223:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                ]),
            ])
            break
        case 224:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                ]),
            ])
            break
        case 225:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                ]),
            ])
            break
        case 226:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                ]),
            ])
            break
        case 227:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 11),
                ]),
            ])
            break
        case 228:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(4/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 13),
                ]),
            ])
            break
        case 229:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(4/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                ]),
            ])
            break
        case 230:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.height(4/6), tag: 6),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                ]),
            ])
            break
        case 231:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(ratio: ViewSize.width(4/6), tag: 6),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                ]),
            ])
            break
        case 236:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(3/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 12),
                ]),
            ])
            break
        case 237:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(4/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                ]),
            ])
            break
        case 238:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(4/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                ]),
            ])
            break
        case 239:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 6),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                ]),
            ])
            break
        case 240:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(3/5), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 10),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 15),
                ]),
            ])
            break
        case 241:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/5), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 9),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 10),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 11),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 15),
                ]),
            ])
            break
        case 242:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 15),
                ]),
            ])
            break
        case 243:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 15),
                ]),
            ])
            break
        case 244:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                ]),
            ])
            break
        case 245:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 10),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 14),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 15),
                ]),
            ])
            break
        case 246:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 10),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 15),
                ]),
            ])
            break
        case 247:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 13),
                ]),
            ])
            break
        case 248:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1.5/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 13),
                ]),
            ])
            break
        case 249:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(2/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 13),
                ]),
            ])
            break
        case 250:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 13),
                ]),
            ])
            break
        case 251:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/5), tag: 8),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 12),
                ]),
            ])
            break
        case 252:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 8),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 12),
                ]),
            ])
            break
        case 253:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 12),
                ]),
            ])
            break
        case 254:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                ]),
            ])
            break
        case 255:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 10),
                ]),
            ])
            break
        case 256:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 9),
                ]),
            ])
            break
        case 257:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 9),
                ]),
            ])
            break
        case 258:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                        ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ]),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ]),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ]),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                ]),
            ])
            break
        case 259:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                        ViewStyle(type: .vstack, ratio: ViewSize.height(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ]),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(type: .vstack, ratio: ViewSize.height(1/2), subViews: [
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                            ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ]),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                ]),
            ])
            break
        case 260:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                ]),
            ])
            break
        case 261:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                ]),
            ])
            break
        case 262:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                ]),
            ])
            break
        case 263:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                ]),
            ])
            break
        case 264:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(5/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 3),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
            ])
            break
        case 265:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(5/7), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/3), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/7), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
            ])
            break
        case 266:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                ]),
            ])
            break
        case 267:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                ]),
            ])
            break
        case 268:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
            ])
            break
        case 269:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                ]),
            ])
            break
        case 270:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 8),
                ]),
            ])
            break
        case 271:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                ]),
            ])
            break
        case 272:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                ]),
            ])
            break
        case 273:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
            ])
            break
        case 274:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                ]),
            ])
            break
        case 275:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 3),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                ]),
            ])
            break
        case 276:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 3),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                ]),
            ])
            break
        case 277:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/4), tag: 8),
                ]),
            ])
            break
        case 278:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                ]),
            ])
            break
        case 279:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                ]),
            ])
            break
        case 280:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/3), tag: 7),
                ]),
            ])
            break
        case 281:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 2),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ]),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                ]),
            ])
            break
        case 282:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.height(2/4), tag: 2),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                    ]),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 5),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 283:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                    ]),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 5),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 284:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 2),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                    ]),
                    ViewStyle(ratio: ViewSize.width(2/4), tag: 5),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                    ]),
                ]),
            ])
            break
        case 285:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(2/3), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/3), subViews: [
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 3),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 4),
                        ViewStyle(ratio: ViewSize.width(1/2), tag: 5),
                    ]),
                    ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                ]),
            ])
            break
        case 286:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/4), tag: 2),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/4), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 4),
                ]),
                ViewStyle(ratio: ViewSize.width(1/4), tag: 5),
            ])
            break
        case 287:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 2),
                ]),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 3),
            ])
            break
        case 288:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
                ViewStyle(ratio: ViewSize.height(2/6), tag: 8),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 10),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 16),
                ]),
            ])
            break
        case 289:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                ]),
                ViewStyle(ratio: ViewSize.width(2/6), tag: 8),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 10),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 16),
                ]),
            ])
            break
        case 292:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 9),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/2), tag: 11),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                ]),
            ])
            break
        case 293:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 6),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 7),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 8),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 9),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/2), tag: 11),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 17),
                ]),
            ])
            break
        case 294:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(2/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(4/6), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ]),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 9),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 11),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 12),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 13),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(2/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 18),
                ]),
            ])
            break
        case 295:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(4/6), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                        ViewStyle(ratio: ViewSize.height(2/4), tag: 7),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                    ]),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 9),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 10),
                        ViewStyle(ratio: ViewSize.height(2/4), tag: 11),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 12),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 18),
                ]),
            ])
            break
        case 296:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.width(3/5), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 7),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.width(3/5), tag: 9),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 10),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(3/5), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 13),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 18),
                ]),
            ])
            break
        case 297:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(3/5), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 5),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 7),
                    ]),
                    ViewStyle(type: .hstack, ratio: ViewSize.width(3/5), subViews: [
                        ViewStyle(ratio: ViewSize.width(1/3), tag: 8),
                        ViewStyle(ratio: ViewSize.width(1/3), tag: 9),
                        ViewStyle(ratio: ViewSize.width(1/3), tag: 10),
                    ]),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/5), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 11),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 12),
                        ViewStyle(ratio: ViewSize.height(1/3), tag: 13),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 14),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 18),
                ]),
            ])
            break
        case 298:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(4/6), subViews: [
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 6),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 7),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 8),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 9),
                    ]),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 10),
                    ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 11),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 12),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 13),
                        ViewStyle(ratio: ViewSize.height(1/4), tag: 14),
                    ]),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 18),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 19),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 20),
                ]),
            ])
            break
        case 299:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 6),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 8),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 18),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 19),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 20),
                ]),
            ])
            break
        case 300:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 6),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 8),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(2/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 16),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 17),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 18),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 19),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 20),
                ]),
            ])
            break
        case 301:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 5),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 6),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 8),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 11),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 14),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.width(4/6), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 17),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 18),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 19),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 20),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 21),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 22),
                    ViewStyle(ratio: ViewSize.width(1/6), tag: 23),
                ]),
            ])
            break
        case 302:
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 2),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 3),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 4),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 5),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 6),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 7),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 8),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 9),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 10),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 11),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 12),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 13),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 14),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 15),
                    ViewStyle(ratio: ViewSize.height(4/6), tag: 16),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 17),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/6), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 18),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 19),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 20),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 21),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 22),
                    ViewStyle(ratio: ViewSize.height(1/6), tag: 23),
                ]),
            ])
            break
        case 303:
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 1),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 3),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 4),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 5),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 6),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 7),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 8),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 9),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 10),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 11),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 12),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 13),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 14),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 15),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 16),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 17),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 18),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 19),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/5), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 20),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 21),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 22),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 23),
                    ViewStyle(ratio: ViewSize.width(1/5), tag: 24),
                ]),
            ])
            break
        case 304:
            let pading = padding + 3
            let x = (viewGridMain.bounds.height / 2) - pading
            let rect = CGRect(x: pading, y: x / 2, width: viewGridMain.bounds.width - (pading + pading), height: x)
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/2), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/2), tag: 1),
            ], isLast: true, rectt: rect)
            break
        case 305:
            let pading = padding + 6
            let x = (viewGridMain.bounds.height / 2) - pading
            let rect = CGRect(x: x / 2, y: pading, width: x, height: viewGridMain.bounds.height - (pading + pading))
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/2), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/2), tag: 1),
            ], isLast: true, rectt: rect)
            break
        case 306:
            let pading = padding + 6
            let x = viewGridMain.bounds.height - (pading + pading)
            let rect = CGRect(x: pading, y: pading, width: x, height: x)
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(4/5), tag: 0),
                    ViewStyle(ratio: ViewSize.width(1/5)),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/5)),
                    ViewStyle(ratio: ViewSize.width(4/5), tag: 1),
                ]),
            ], isLast: true, rectt: rect)
            break
        case 307:
            let pading = padding + 6
            let x = viewGridMain.bounds.height - (pading + pading)
            let rect = CGRect(x: pading, y: pading, width: x, height: x)
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/5)),
                    ViewStyle(ratio: ViewSize.height(4/5), tag: 0),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/2), subViews: [
                    ViewStyle(ratio: ViewSize.height(4/5), tag: 1),
                    ViewStyle(ratio: ViewSize.height(1/5)),
                ]),
            ], isLast: true, rectt: rect)
            break
        case 308:
            let pading = padding + 6
            let x = (viewGridMain.bounds.height / 3) - pading
            let rect = CGRect(x: pading, y: (viewGridMain.bounds.height / 2) - (x / 2), width:  viewGridMain.bounds.width - (pading + pading), height: x)
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.width(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 1),
                ViewStyle(ratio: ViewSize.width(1/3), tag: 2),
            ], isLast: true, rectt: rect)
            break
        case 309:
            let pading = padding + 6
            let x = (viewGridMain.bounds.height / 3) - pading
            let rect = CGRect(x: (viewGridMain.bounds.height / 2) - (x / 2), y: pading, width: x, height: viewGridMain.bounds.height - (pading + pading))
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(ratio: ViewSize.height(1/3), tag: 0),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 1),
                ViewStyle(ratio: ViewSize.height(1/3), tag: 2),
            ], isLast: true, rectt: rect)
            break
        case 310:
            let pading = padding + 6
            let x = viewGridMain.bounds.height - (pading + pading)
            let rect = CGRect(x: pading, y: pading, width: x, height: x)
            createView(baseView: .hstack, viewStyleList: [
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(5/6), tag: 0),
                    ViewStyle(ratio: ViewSize.height(1/6)),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(0.5/6)),
                    ViewStyle(ratio: ViewSize.height(5/6), tag: 1),
                    ViewStyle(ratio: ViewSize.height(0.5/6)),
                ]),
                ViewStyle(type: .vstack, ratio: ViewSize.width(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.height(1/6)),
                    ViewStyle(ratio: ViewSize.height(5/6), tag: 2),
                ]),
            ], isLast: true, rectt: rect)
            break
        case 311:
            let pading = padding + 6
            let x = viewGridMain.bounds.height - (pading + pading)
            let rect = CGRect(x: pading, y: pading, width: x, height: x)
            createView(baseView: .vstack, viewStyleList: [
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(1/6)),
                    ViewStyle(ratio: ViewSize.width(5/6), tag: 0),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(0.5/6)),
                    ViewStyle(ratio: ViewSize.width(5/6), tag: 1),
                    ViewStyle(ratio: ViewSize.width(0.5/6)),
                ]),
                ViewStyle(type: .hstack, ratio: ViewSize.height(1/3), subViews: [
                    ViewStyle(ratio: ViewSize.width(5/6), tag: 2),
                    ViewStyle(ratio: ViewSize.width(1/6)),
                ]),
            ], isLast: true, rectt: rect)
            break
        default:
            break
        }
    }
    
    func createShape(index: Int, ptArr: [ShapeType]) {
        
        var newPArr = [CGPoint]()
        var pathPArr = [CGPoint]()
        
        ptArr.enumerated().forEach { i, pr in
            print("i --- ",index)
            switch pr {
            case .point(let p, let pad):
                //                pathPArr.append(CGPoint(x: p.x+(pad[0]*(padding/2)), y: p.y+(pad[1]*(padding/2))))
                pathPArr.append(p)
                newPArr.append(p)
                break
            case .angle(let a, let cpI, let r, let line, let pad):
                let cp = points[cpI[0]][cpI[1]]
                
                var rd = r
                if r == -1 {
                    rd = viewGridMain.bounds.width+100
                }
                let p = CGPoint(x: cp.x + sin(a.degreesToRadians) * rd, y: cp.y + cos(a.degreesToRadians) * rd)
                if r == -1 {
                    let pxy = linesCross(start1: cp, end1: p, start2: line[0], end2: line[1])
                    let p3 = CGPoint(x: pxy?.x ?? 0, y: pxy?.y ?? 0)
                    pathPArr.append(p3)
                    newPArr.append(p3)
                } else {
                    pathPArr.append(p)
                    newPArr.append(p)
                }
                break
            }
            if points.count == index+1 {
                points[index] = newPArr
            } else {
                points.append(newPArr)
            }
        }
        
        let aPath = CGMutablePath()
                
        pathPArr.enumerated().forEach { i, pt in
            let nextIndex = (i + 1) % pathPArr.count
            if i == 0 {
                aPath.move(to: pt)
            } else {
                aPath.addArc(tangent1End: pt, tangent2End: pathPArr[nextIndex], radius: cornerRadius)
                print("currentPoint --- ", aPath.currentPoint)
            }
        }
        aPath.addArc(tangent1End: pathPArr[0], tangent2End: pathPArr[1], radius: cornerRadius)
        aPath.closeSubpath()

        let strokePath = UIBezierPath(cgPath: aPath.copy(strokingWithWidth: padding, lineCap: .round, lineJoin: .round, miterLimit: .zero))
        let cPath = UIBezierPath(cgPath: aPath)
        cPath.append(UIBezierPath(cgPath: strokePath.cgPath))
        cPath.usesEvenOddFillRule = true

        let v = ShapeView(frame: viewGridMain.bounds)
        v.backgroundColor = UIColor.systemGray6
        v.addMask(path: cPath.cgPath)
        viewGridMain.addSubview(v)

        let img = ZoomImageView(frame: cPath.cgPath.boundingBox)
        let image = allImages[index]["image"] as? UIImage ?? UIImage()
        if image != UIImage() {
            img.image = image
            img.zoomMode = .fill
        }
        img.tag = index
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapImage(_:)))
        img.addGestureRecognizer(tap)
        img.isUserInteractionEnabled = true
        img.clipsToBounds  = true
        v.addSubview(img)

    }
    
    func createViewWithMaskCurve(list: [(dir: CurveDirection, shapes: [[CGFloat]])]) {
        print("Main Rect --- ", viewGridMain.bounds)
        list.enumerated().forEach { i, l in
            let rect = viewGridMain.bounds.insetBy(dx: padding/2, dy: padding/2)
            print("Rect --- ", rect)
            createCurve(rect: rect, shapeList: l.shapes, tag: i, dir: l.dir)
        }
    }
    
    func createCurve(rect: CGRect, shapeList: [[CGFloat]], tag: Int, dir: CurveDirection = .top) {
        let v = ShapeView(frame: rect)
        v.backgroundColor = UIColor.systemGray6
        
        let cgrect = v.bounds
        
        let shapes = shapeList.toPointC(rect: v.bounds, padding: padding/2)
        print("Shape --- ", shapes)
        
        let aPath = CGMutablePath()
        aPath.move(to: CGPoint(x: shapes[0].x, y: shapes[0].y))
        aPath.addLine(to: CGPoint(x: shapes[1].x, y: shapes[1].y))
        let p = CGPoint(x: shapes[2].x, y: shapes[2].y)
        aPath.addLine(to: p)
        
        if dir == .top {
            let cp1 = CGPoint(x: (cgrect.size.width)/2, y: 0)
            let cp2 = CGPoint(x: (cgrect.size.width)/2, y: cgrect.size.height-padding)
            let p3 = CGPoint(x: shapes[3].x, y: shapes[3].y)
            aPath.addCurve(to: p3, control1: cp1, control2: cp2)
        } else if dir == .bottom {
            let cp1 = CGPoint(x: (cgrect.size.width)/2, y: padding)
            let cp2 = CGPoint(x: (cgrect.size.width)/2, y: cgrect.size.height)
            let p3 = CGPoint(x: shapes[3].x, y: shapes[3].y)
            aPath.addCurve(to: p3, control1: cp1, control2: cp2)
        } else if dir == .left {
            let cp1 = CGPoint(x: 0, y: cgrect.size.height*0.50)
            let cp2 = CGPoint(x: cgrect.size.width-padding, y: cgrect.size.height*0.50)
            let p3 = CGPoint(x: shapes[3].x, y: shapes[3].y)
            aPath.addCurve(to: p3, control1: cp1, control2: cp2)
        } else {
            let cp1 = CGPoint(x: padding, y: cgrect.size.height*0.50)
            let cp2 = CGPoint(x: cgrect.size.width, y: cgrect.size.height*0.50)
            let p3 = CGPoint(x: shapes[3].x, y: shapes[3].y)
            aPath.addCurve(to: p3, control1: cp1, control2: cp2)
        }
        
        aPath.closeSubpath()
        
        v.addMask(path: aPath)
        viewGridMain.addSubview(v)
        
        let img = ZoomImageView(frame: aPath.boundingBoxOfPath)
        v.addSubview(img)
        let image = allImages[tag]["image"] as? UIImage ?? UIImage()
        if image != UIImage() {
            img.image = image
            img.zoomMode = .fill
        } else {
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            //                let imageView = UIImageView(frame: CGRect(x: (v.bounds.width / 2) - 15, y: (v.bounds.height / 2) - 15, width: 30, height: 30))
            //                imageView.image = UIImage(named: "ic_add_text")
            //                imageView.tintColor = UIColor.darkGray
            //                imageView.tag = 101
            //                img.addSubview(imageView)
            //            }
            
            img.backgroundColor = UIColor.systemGray6
        }
        img.tag = tag
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapImage(_:)))
        img.addGestureRecognizer(tap)
        img.isUserInteractionEnabled = true
    }
    
    func createView(baseView: ViewType = .vstack, viewStyleList: [ViewStyle], isLast: Bool = false, rectt: CGRect = .zero) {
        var rect = CGRect()
        if isLast {
            rect = rectt
        } else {
            rect = viewGridMain.bounds.insetBy(dx: padding / 2, dy: padding / 2)
        }
        let vws = createView2(viewStyleList: viewStyleList, size: rect.size, isLast: isLast)
        let stack = UIStackView(arrangedSubviews: vws)
        stack.distribution = .fill
        stack.spacing = isLast ? 5 : 0
        stack.alignment = .fill
        stack.axis = baseView == .vstack ? .vertical : .horizontal
        stack.frame = rect
        viewGridMain.addSubview(stack)
    }
    
    func createView2(viewStyleList: [ViewStyle], size: CGSize, isLast: Bool) -> [UIView] {
        var vws = [UIView]()
        
        viewStyleList.forEach { vs in
            
            var sizee = size
            switch vs.ratio {
            case .height(let ht):
                sizee.height = sizee.height * ht
                break
            case .width(let wd):
                sizee.width = sizee.width * wd
                break
            }
            
            switch vs.type {
            case .hstack:
                let v = createView2(viewStyleList: vs.subViews, size: sizee, isLast: isLast)
                let hstack = UIStackView(arrangedSubviews: v)
                hstack.distribution = .fill
                hstack.alignment = .fill
                hstack.axis = .horizontal
                vws.append(hstack)
                break
            case .vstack:
                let v = createView2(viewStyleList: vs.subViews, size: sizee, isLast: isLast)
                let vstack = UIStackView(arrangedSubviews: v)
                vstack.distribution = .fill
                vstack.alignment = .fill
                vstack.axis = .vertical
                vws.append(vstack)
                break
            case .view:
                let v = UIView()
                v.backgroundColor = UIColor.clear
                
                v.translatesAutoresizingMaskIntoConstraints = false
                v.widthAnchor.constraint(equalToConstant: sizee.width).isActive = true
                v.heightAnchor.constraint(equalToConstant: sizee.height).isActive = true
                
                let img = ZoomImageView()
                img.translatesAutoresizingMaskIntoConstraints = false
                img.cornerRadius = self.cornerRadius
                v.addSubview(img)
                img.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
                img.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                img.heightAnchor.constraint(equalTo: v.heightAnchor, constant: -padding).isActive = true
                img.widthAnchor.constraint(equalTo: v.widthAnchor, constant: -padding).isActive = true
                
                if vs.tag != -1 {
                    let image = allImages[vs.tag]["image"] as? UIImage ?? UIImage()
                    if image != UIImage() {
                        img.image = image
                        img.zoomMode = .fill
                    } else {
                        //                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        //                        let imageView = UIImageView(frame: CGRect(x: (v.bounds.width / 2) - 15, y: (v.bounds.height / 2) - 15, width: 30, height: 30))
                        //                        imageView.image = UIImage(named: "ic_add_text")
                        //                        imageView.tintColor = UIColor.darkGray
                        //                        imageView.tag = 101
                        //                        img.addSubview(imageView)
                        //                    }
                        
                        img.backgroundColor = UIColor.systemGray6
                    }
                    img.tag = vs.tag
                    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapImage(_:)))
                    img.addGestureRecognizer(tap)
                    
                    if isLast {
                        v.backgroundColor = .white
                        v.cornerRadius = 8
                        
                        img.borderColor = UIColor.white
                        img.borderWidthh = 2
                        img.cornerRadius = 13
                    }
                }
                vws.append(v)
                break
            }
        }
        return vws
    }
    
    @objc func handleTapImage(_ sender: UITapGestureRecognizer) {
        btnSelection(sender.view?.tag ?? 0)
    }
    
    func createViewsWithMask(list: [(cgrect: [CGFloat], shapes: [[CGFloat]])]) {
        print("Main Rect --- ", viewGridMain.bounds)
        list.enumerated().forEach { i, l in
            let rectt = l.cgrect.toRect(size: viewGridMain.bounds.size)
            print("Rect --- ", rectt)
            
            var rect = rectt
            //            if i == 0 {
            //                let lineWidth: CGFloat = padding
            //                let top = lineWidth / sin(atan(0.5))
            //                let bottom = lineWidth
            //                let horizontal = (top + bottom) / 2
            //
            //                rect = rectt.inset(by:
            //                                        UIEdgeInsets(
            //                                            top: bottom,
            //                                            left: bottom,
            //                                            bottom: top,
            //                                            right: horizontal
            //                                        )
            //                )
            //
            //            }
            
            
            let shape = l.shapes.toPoint(size: rect.size, padding: 0)
            print("Shape --- ", shape)
            createViewWithMask(cgrect: rect, shapes: shape)
            //            if i == 0 {
            //                let v = TriangleView(frame: rect)
            //                viewMain.addSubview(v)
            //            }
        }
    }
    
    func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> (x: CGFloat, y: CGFloat)? {
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y
        
        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y
        
        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }
        
        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant
        
        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant
            
            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                let intersectX = start1.x + ab * delta1x
                let intersectY = start1.y + ab * delta1y
                return (intersectX, intersectY)
            }
        }
        
        // lines don't cross
        return nil
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func createViewWithMask(cgrect: CGRect, shapes: [CGPoint]) {
        let v = UIView(frame: cgrect)
        v.backgroundColor = UIColor.clear
        
        //        let rect = v.bounds
        let aPath = CGMutablePath()
        
        shapes.enumerated().forEach { i, pt in
            if i == 0 {
                aPath.move(to: pt)
            } else {
                aPath.addArc(tangent1End: shapes[i], tangent2End: shapes[i+1 == shapes.count ? 0 : i+1], radius: cornerRadius)
                print("currentPoint --- ", aPath.currentPoint)
            }
        }
        aPath.addArc(tangent1End: shapes[0], tangent2End: shapes[1], radius: cornerRadius)
        aPath.closeSubpath()
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.strokeColor = UIColor.systemGreen.cgColor
        maskLayer.lineWidth = 0
        //        maskLayer.fillRule = .evenOdd
        
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.white.cgColor
        shape.strokeColor = UIColor.purple.cgColor
        shape.lineWidth = 0//padding
        
        shape.path = aPath
        maskLayer.path = aPath
        //        shape.mask = maskLayer
        
        //        v.layer.backgroundColor = UIColor.green.cgColor
        //        v.layer.borderWidth = 5
        //        v.layer.borderColor = UIColor.black.cgColor
        //        v.layer.addSublayer(shape)
        v.layer.mask = shape
        
        viewGridMain.addSubview(v)
        
        //        v.layer.masksToBounds = true
        v.clipsToBounds = true
        
        let img = ZoomImageView(frame: v.bounds)
        //        img.layer.masksToBounds = true
        v.addSubview(img)
        img.clipsToBounds  = true
        //        if !arrOfTotalImg.isEmpty {
        //            img.image = arrOfTotalImg.removeFirst()
        //        } else {
        //            img.image = UIImage(named: "placeholder")
        //        }
        img.zoomMode = .fill
        img.tag = v.tag
        
        //        shape.mask = img.layer
    }
    
    // Mark :- Old Code
    func addTextLabel(_ txt : String) {
        viewMain.addLabel()
        viewMain.textColor = UIColor.black
        viewMain.currentlyEditingLabel.labelTextView?.isUserInteractionEnabled = false
        viewMain.currentlyEditingLabel.closeView!.image = UIImage(named: "ic_cancle")
        viewMain.currentlyEditingLabel.closeView!.tintColor = UIColor.black
        viewMain.currentlyEditingLabel.closeView!.cornerRadius = 16
        
        viewMain.currentlyEditingLabel.rotateView?.image = UIImage(named: "ic_scale_white")
        viewMain.currentlyEditingLabel.rotateView!.tintColor = UIColor.black
        viewMain.currentlyEditingLabel.rotateView?.cornerRadius = 16
        viewMain.currentlyEditingLabel.labelTextView?.font = UIFont.systemFont(ofSize: 44.0)
        
        viewMain.currentlyEditingLabel.labelTextView?.alignment = .center
        viewMain.currentlyEditingLabel.labelTextView?.text = txt
        viewMain.currentlyEditingLabel.objViewHidden = self
        self.dismiss(animated: true, completion: nil)
    }
    
    func setStickers(_ img : UIImage) {
        let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 140, height: 140))
        testImage.image = img
        
        let stickerView = StickerView.init(contentView: testImage)
        stickerView.center = CGPoint.init(x: 150, y: 150)
        stickerView.delegate = self
        stickerView.setImage(UIImage.init(named: "ic_cancle")!, forHandler: StickerViewHandler.close)
        stickerView.setImage(UIImage.init(named: "ic_scale_white")!, forHandler: StickerViewHandler.rotate)
        stickerView.showEditing = false
        self.viewMain.addSubview(stickerView)
        self.selectedStickerView = stickerView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        stickerView.addGestureRecognizer(tap)
        stickerView.isUserInteractionEnabled = true
    }
    
    @objc func update1() {
        SVProgressHUD.dismiss()
    }
    
    func displayMyAlertMessage(userMessage:String) {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnDown3Action(_ sender: Any) {
        viewReplaceImg.isHidden = true
        viewMainItems.isHidden = false
        setView(view: viewMainItems)
    }
    
    func btnSelection(_ obj : Int) {
        objPickIndex = obj
        let images = viewGridMain.allSubViewsOf(type: ZoomImageView.self)
        images.forEach { imageView in
            if imageView.tag == objPickIndex {
                if (allImages[objPickIndex]["image"] as? UIImage) == UIImage() {
                    openGallary()
                    isSelectGallery = true
                } else {
                    viewReplaceImg.isHidden = false
                    setView(view: viewReplaceImg)
                    viewMainItems.isHidden = true
                    viewShapes.isHidden = true
                    viewTextEditor.isHidden = true
                    imgFilter = imageView.image ?? UIImage()
                }
            }
        }
    }
    
    func replaceImg(image: UIImage) {
        let images = viewGridMain.allSubViewsOf(type: ZoomImageView.self)
        images.forEach { imageView in
            if imageView.tag == objPickIndex {
                imageView.image = image
            }
        }
        allImages[objPickIndex]["image"] = image
    }
    
    @IBAction func btnReplaceAction(_ sender: UIButton) {
        openGallary()
        isSelectGallery = true
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        if objType == 1 {
            self.objpresentPhotoVC.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }else if objType == 2 {
            self.objpresentPhotoVC.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.selectedStickerView?.showEditing = false
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        SVProgressHUD.show()
        DispatchQueue.main.async {
            self.selectedStickerView?.showEditing = false
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
        }
    }
    
    //MARK:- Custom Function
    @objc func update() {
        saveScreenShotImage()
        SVProgressHUD.dismiss()
    }
    func saveScreenShotImage(){
        let obj : ShareVC = self.storyboard?.instantiateViewController(withIdentifier: "ShareVC") as! ShareVC
        UIGraphicsBeginImageContextWithOptions(self.viewMain.bounds.size, self.viewMain.isOpaque, 0.0)
        self.viewMain.drawHierarchy(in: self.viewMain.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        obj.getImage = snapshotImageFromMyView!
        obj.objDisplay = 1
        if userDefault.object(forKey: "img") == nil{
            let data = obj.getImage.pngData()
            obj.arrAddImage.add(data!)
            userDefault.set(obj.arrAddImage, forKey: "img")
            userDefault.synchronize()
        }else{
            let data = obj.getImage.pngData()
            let tempNames: NSArray = ((userDefault.object(forKey: "img")as AnyObject) as! NSArray)
            obj.arrAddImage = tempNames.mutableCopy() as! NSMutableArray
            obj.arrAddImage.insert(data!, at: 0)
            userDefault.set(obj.arrAddImage, forKey: "img")
            userDefault.synchronize()
        }
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnDownAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        self.viewShapes.isHidden = true
        viewReplaceImg.isHidden = true
        setView(view: self.viewMainItems)
        self.viewMainItems.isHidden = false
    }
    
    @IBAction func btnKeyboardAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
        obj.isFromEditImageStk = true
        obj.objSelection = 2
        obj.objImgStk = self
        self.present(obj, animated: true, completion: nil)
    }
    @IBAction func btnFontStyleAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        self.objSelectTxtValue = 2
        viewAlign.isHidden = true
        viewColorPicker.isHidden = true
        tblFontStyle.isHidden = false
        tblFontStyle.reloadData()
    }
    @IBAction func btnColorAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        viewColorPicker.isHidden = false
        viewAlign.isHidden = true
        setColor()
    }
    @IBAction func btnAlignAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        viewAlign.isHidden = false
        tblFontStyle.isHidden = true
        viewColorPicker.isHidden = true
    }
    
    @IBAction func btnAddTextAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
        obj.isFromEditImageStk = true
        obj.objSelection = 3
        obj.objImgStk = self
        self.present(obj, animated: true, completion: nil)
    }
    
    @IBAction func btnDown1Action(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        selectedStickerView?.showEditing = false
        viewMain.currentlyEditingLabel.hideEditingHandlers()
        viewTextEditor.isHidden = true
        viewReplaceImg.isHidden = true
        setView(view: viewMainItems)
        viewMainItems.isHidden = false
    }
    
    @IBAction func btnLeftAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .left
    }
    
    @IBAction func btnCenterAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .center
    }
    
    @IBAction func btnRightAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .right
    }
    
    @IBAction func sliderOpacityAction(_ sender: UISlider) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        let currentValue = CGFloat(sender.value)
        viewMain.currentlyEditingLabel.labelTextView?.alpha = currentValue
    }
    
    //MARK:- Button Action Zone
    @IBAction func btnFilterAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        self.lblTitle.text = "Filters"
        self.viewShapes.isHidden = false
        self.ShapeCV.isHidden = true
        self.FxCV.isHidden = true
        self.BackGroundCV.isHidden = true
        self.FilterCV.isHidden = false
        setView(view: self.viewShapes)
        self.viewReplaceImg.isHidden = true
        self.viewMainItems.isHidden = true
    }
    
    @IBAction func btnFlipVAction(_ sender: UIButton) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        if btnFlipV.isSelected == true {
        } else {
            let images = viewGridMain.allSubViewsOf(type: ZoomImageView.self)
            images.forEach { imageView in
                if imageView.tag == objPickIndex {
                    if imageView.transform == value2 {
                        imageView.transform = val
                    } else {
                        imageView.transform = value2
                    }
                }
            }
        }
    }
    
    @IBAction func btnFlipHAction(_ sender: Any) {
        loadInterstitial()
        CLICK_COUNT += 1
        if CLICK_COUNT == UserDefaults.standard.integer(forKey: "AD_COUNT") {
            CLICK_COUNT = 0
            TrigerInterstitial()
        }
        if btnFlipH.isSelected == true {
        } else {
            let images = viewGridMain.allSubViewsOf(type: ZoomImageView.self)
            images.forEach { imageView in
                if imageView.tag == objPickIndex {
                    if imageView.transform == value1 {
                        imageView.transform = val
                    } else {
                        imageView.transform = value1
                    }
                }
            }
        }
    }
    
    func setColor() {
        colorPicker.delegate = self
        colorPicker.layoutDelegate = self
        colorPicker.isSelectedColorTappable = true
        colorPicker.style = .circle
        colorPicker.selectionStyle = .check
        colorPicker.backgroundColor = .clear
    }
    
}

extension ImageEditActionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            allImages[objPickIndex]["image"] = pickedImage
            imgFilter = pickedImage
            let images = viewGridMain.allSubViewsOf(type: ZoomImageView.self)
            
            images.forEach { imageView in
                if imageView.tag == objPickIndex {
                    for v in imageView.subviews {
                        if v is UIImageView, v.tag == 101 {
                            v.removeFromSuperview()
                        }
                    }
                    imageView.image = pickedImage
                    imageView.zoomMode = .fill
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
        viewReplaceImg.isHidden = true
        viewMainItems.isHidden = false
        setView(view: viewMainItems)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImageEditActionVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK:- CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == ShapeCV {
            return 13
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objType == 1 {
            if collectionView == self.mainItemsCV {
                return arrOfMain.count
            } else if collectionView == ShapeCV {
                return allFramesJson[section].count
            } else if collectionView == BackGroundCV {
                return 19
            } else if collectionView == self.FilterCV {
                return arrOfFilter.count
            } else if collectionView == self.FxCV {
                return arrOfFx.count
            } else {
                return 0
            }
        } else if objType == 2 {
            if collectionView == self.mainItemsCV {
                return arrOfSingleMain.count
            } else if collectionView == self.FilterCV {
                return arrOfFilter.count
            } else if collectionView == self.FxCV {
                return arrOfFx.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.mainItemsCV{
            let cell: SelectItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCell
            if cell.btnItem == (cell.viewWithTag(10) as? UIButton) {
                if objType == 1 {
                    cell.imgItem.image = UIImage(named: arrOfMain[indexPath.row])
                    cell.btnItem.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == 0 {
                            btn.isEnabled = true
                            self.viewShapes.isHidden = false
                            self.lblTitle.text = "Layouts"
                            self.BackGroundCV.isHidden = true
                            self.FilterCV.isHidden = true
                            self.ShapeCV.isHidden = false
                            self.FxCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.viewMainItems.isHidden = true
                        } else if indexPath.row == 1 {
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            self.FxCV.isHidden = true
                            self.BackGroundCV.isHidden = false
                            self.FilterCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.lblTitle.text = "BackGrounds"
                            self.viewMainItems.isHidden = true
                        } else if indexPath.row == 2 {
                            btn.isEnabled = true
                            let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
                            obj.isFromEditImageStk = true
                            obj.objImgStk = self
                            obj.objSelection = 1
                            self.present(obj, animated: true, completion: nil)
                        } else if indexPath.row == 3 {
                            btn.isEnabled = true
                            let obj : StickersVC = self.storyboard?.instantiateViewController(withIdentifier: "StickersVC") as! StickersVC
                            obj.isFromEditImageStk = true
                            obj.objImageStk = self
                            obj.objStickerSelecion = 1
                            self.navigationController?.pushViewController(obj, animated: true)
                        } else if indexPath.row == 4 {
                            btn.isEnabled = true
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.FilterCV.isHidden = true
                            self.BackGroundCV.isHidden = true
                            self.FxCV.isHidden = false
                            self.lblTitle.text = "Textures"
                            self.viewMainItems.isHidden = true
                        }
                    }
                } else if objType == 2 {
                    cell.imgItem.image = UIImage(named: arrOfSingleMain[indexPath.row])
                    cell.btnItem.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == 0 {
                            btn.isEnabled = true
                            let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
                            obj.isFromEditImageStk = true
                            obj.objImgStk = self
                            obj.objSelection = 1
                            self.present(obj, animated: true, completion: nil)
                        } else if indexPath.row == 1 {
                            btn.isEnabled = true
                            let obj : StickersVC = self.storyboard?.instantiateViewController(withIdentifier: "StickersVC") as! StickersVC
                            obj.isFromEditImageStk = true
                            obj.objImageStk = self
                            obj.objStickerSelecion = 1
                            self.navigationController?.pushViewController(obj, animated: true)
                        } else if indexPath.row == 2 {
                            btn.isEnabled = true
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.FilterCV.isHidden = true
                            self.BackGroundCV.isHidden = true
                            self.FxCV.isHidden = false
                            self.lblTitle.text = "Textures"
                            self.viewMainItems.isHidden = true
                        } else if indexPath.row == 3 {
                            self.lblTitle.text = "Filters"
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            self.FxCV.isHidden = true
                            self.BackGroundCV.isHidden = true
                            self.FilterCV.isHidden = false
                            setView(view: self.viewShapes)
                            self.viewReplaceImg.isHidden = true
                            self.viewMainItems.isHidden = true
                        }
                    }
                }
            }
            return cell
            
        } else if collectionView == ShapeCV {
            let cell : StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
            let ddd = allFramesJson[indexPath.section]
            let dict = ddd[indexPath.item]
            cell.imgSelection.image = UIImage(named: "\(dict["image"] ?? 0)")
            cell.imgSelection.tintColor = .white
            if cell.btnImage == (cell.viewWithTag(5) as? UIButton){
                cell.btnImage.mk_addTapHandlerIO { (btn) in
                    for v in self.viewGridMain.subviews {
                        v.removeFromSuperview()
                    }
                    btn.isEnabled = true
                    let parts = dict["parts"] ?? 0
                    for _ in 0..<parts {
                        if self.allImages.count < parts {
                            let dict = ["image" : UIImage(), "index": IndexPath()] as [String : Any]
                            self.allImages.append(dict)
                        }
                    }
                    let index = dict["image"] ?? 0
                    self.points = []
                    self.viewBasedOnIndex(ix: index - 1)
                }
            }
            return cell
            
        } else if collectionView == BackGroundCV {
            let cell: FramesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FramesCell", for: indexPath) as! FramesCell
            
            if cell.btnFrame == (cell.viewWithTag(15) as? UIButton) {
                cell.imgFrame.image = UIImage(named: "\(indexPath.row+1)_BG")
                cell.btnFrame.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.imgTexture.isHidden = false
                    self.imgTexture.isUserInteractionEnabled = false
                    self.imgBackground.isHidden = false
                    let img = UIImage(named: "\(indexPath.row+1)_BG")
                    if indexPath.row == arrOfIndex[indexPath.row]{
                        self.imgBackground.image = img
                        self.imgBackground.isUserInteractionEnabled = false
                    }
                }
            }
            return cell
            
        } else if collectionView == self.FxCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FramesCell", for: indexPath) as! FramesCell
            if cell.btnFrame == (cell.viewWithTag(15) as? UIButton) {
                cell.imgFrame.image = UIImage(named: arrOfFx[indexPath.row])
                cell.imgCommon.image = UIImage(named: "sample")
                cell.btnFrame.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.imgTexture.isHidden = false
                    let img = UIImage(named: arrOfFx[indexPath.row])
                    if indexPath.row == arrOfIndex[indexPath.row] {
                        self.imgTexture.image = img
                        self.imgTexture.isUserInteractionEnabled = false
                    }
                }
            }
            return cell
            
        } else if collectionView == self.FilterCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
            
            if cell.btnFilters == (cell.viewWithTag(20) as? UIButton) {
                
                cell.imgCommon.image = UIImage(named: "sample")
                cell.lblTitles.text = arrOfFilter[indexPath.row]
                
                cell.btnFilters.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    if indexPath.row == 0 {
                        self.replaceImg(image: self.imgFilter)
                    } else if indexPath.row == 1 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectChrome")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 2 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectFade")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 3 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectInstant")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 4 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectMono")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 5 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectNoir")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 6 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectProcess")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 7 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectTonal")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 8 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectTransfer")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 9 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CILinearToSRGBToneCurve")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 10 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CISepiaTone")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 11 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIGaussianBlur")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 12 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CIExposureAdjust", key: kCIInputEVKey, value: 1)
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 13 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CIVignette", key: kCIInputIntensityKey, value: 5)
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 14 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 =  getScannedImage(inputImage: self.imgFilter) ?? UIImage()
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 15 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CISharpenLuminance", key: kCIInputSharpnessKey, value: 10)
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    } else if indexPath.row == 16 {
                        SVProgressHUD.show()
                        DispatchQueue.main.async {
                            let img1 = applyFilter(image: self.imgFilter, filterName: "CIColorInvert")
                            self.replaceImg(image: img1)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                        }
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.mainItemsCV{
            if objType == 1{
                return CGSize(width: 45, height: 45)
            }else if objType == 2{
                return CGSize(width: 45, height: 45)
            }
        }else if collectionView == self.ShapeCV{
            return CGSize(width: 70, height: 70)
        }else if collectionView == self.BackGroundCV || collectionView == self.FxCV{
            return CGSize(width: 80, height: 80)
        }else if collectionView == self.FilterCV{
            return CGSize(width: 90, height: 90)
        };return CGSize()
    }
}

extension ImageEditActionVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfFontType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : tblStyleCell = tableView.dequeueReusableCell(withIdentifier: "tblStyleCell", for: indexPath) as! tblStyleCell
        if cell.btnStyleValue == (cell.viewWithTag(30) as? UIButton) {
            cell.btnStyleValue.titleLabel?.font = UIFont(name: arrOfFontType[indexPath.row], size: 26)
            cell.btnStyleValue.setTitle("Sample Text", for: .normal)
            cell.btnStyleValue.mk_addTapHandlerIO { (btn) in
                btn.isEnabled = true
                let textLabel = self.viewMain.currentlyEditingLabel.labelTextView
                let font = self.viewMain.currentlyEditingLabel.labelTextView!.fontSize
                if indexPath.row == arrOfIndex[indexPath.row]{
                    textLabel?.font = UIFont(name: arrOfFontType[indexPath.row], size: font)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ImageEditActionVC : ColorPickerViewDelegate, ColorPickerViewDelegateFlowLayout {
    
    //MARK:- Color Pickerview Delegate Methods
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        viewMain.currentlyEditingLabel.labelTextView?.textColor = colorPickerView.colors[indexPath.item]
    }
    
    // MARK: - ColorPickerViewDelegateFlowLayout
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension ImageEditActionVC : StickerViewDelegate {
    
    //MARK:- StickerView Delegate
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    func stickerViewDidChangeMoving(_ stickerView: StickerView) {}
    func stickerViewDidEndMoving(_ stickerView: StickerView) {}
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {}
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {}
    func stickerViewDidEndRotating(_ stickerView: StickerView) {}
    @objc func stickerViewDidClose(_ stickerView: StickerView) {}
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
}

class ShapeView: UIView {
    
    var path: CGPath? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMask(path: CGPath) {
        self.clipsToBounds = true
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.lineWidth = 0
        maskLayer.fillColor = UIColor.red.cgColor
        self.layer.mask = maskLayer
        self.layer.masksToBounds = true
        self.path = path
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let p = path, p.contains(point) {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}

extension ImageEditActionVC {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadInterstitial()
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
    func loadInterstitial() {
        let adRequest = GADRequest()
        if let adUnitID1 = UserDefaults.standard.string(forKey: "INTERSTITIAL_ID") {
        GADInterstitialAd.load(withAdUnitID: adUnitID1, request: adRequest) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
        }
    }
    
    func TrigerInterstitial() {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Interstitial ad is not ready yet.")
        }
    }
}
