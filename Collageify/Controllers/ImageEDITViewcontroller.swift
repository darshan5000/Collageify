
import UIKit
import CoreGraphics
import IGColorPicker
import ImageScrollView
import SVProgressHUD
import Firebase
import ZoomImageView
import GoogleMobileAds

class ImageEDITViewcontroller: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,StickerViewDelegate,ColorPickerViewDelegate,ColorPickerViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    var objType = 0
    var arrOfTotalImg = [UIImage]()
    var imgFilter = UIImage()
    var objpresentPhotoVC = CurrentPhotoVC()
    var imgValue = UIImage()
    var objIndex = 0
    var isSelectGallery = false
    var objPickImage = 0
    var objSelectTxtValue = 0
    private var interstitial: GADInterstitialAd?
    var isImageEmpty = false
    var imgIndex = 0
    var imagePicker = UIImagePickerController()

    //MARK:- Outlets
    @IBOutlet weak var lblMainTitle: UILabel!
    @IBOutlet weak var viewMain: JLStickerImageView!
    @IBOutlet weak var viewSinglePhoto: UIView!
    @IBOutlet weak var imgSingleBackground: UIImageView!
    @IBOutlet weak var imgSingle: ZoomImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgFX: UIImageView!
    @IBOutlet weak var view1Photo: UIView!
    @IBOutlet weak var view1_1: UIView!
    @IBOutlet weak var img1_1: ZoomImageView!
    @IBOutlet weak var btn1_1: UIButton!
    
    @IBOutlet weak var view1_2: UIView!
    @IBOutlet weak var img1_2: ZoomImageView!
    @IBOutlet weak var btn1_2: UIButton!
    
    @IBOutlet weak var viewTriangleShape: UIView!
    @IBOutlet weak var viewTriangle: UIView!
    @IBOutlet weak var imgTriangle: ZoomImageView!
    @IBOutlet weak var btnTriangle: UIButton!
    @IBOutlet weak var view2Photo: UIView!
    @IBOutlet weak var view2_1: UIView!
    @IBOutlet weak var img2_1: ZoomImageView!
    @IBOutlet weak var btn2_1: UIButton!
    @IBOutlet weak var view2_2: UIView!
    @IBOutlet weak var img2_2: ZoomImageView!
    @IBOutlet weak var btn2_2: UIButton!
    
    @IBOutlet weak var viewWhite: UIView!
    @IBOutlet weak var view3Photo: UIView!
    @IBOutlet weak var view3_1: UIView!
    @IBOutlet weak var img3_1: ZoomImageView!
    @IBOutlet weak var btn3_1: UIButton!
    @IBOutlet weak var view3_2: UIView!
    @IBOutlet weak var img3_2: ZoomImageView!
    @IBOutlet weak var btn3_2: UIButton!
    @IBOutlet weak var view3_3: UIView!
    @IBOutlet weak var img3_3: ZoomImageView!
    @IBOutlet weak var btn3_3: UIButton!
    
    @IBOutlet weak var view4Photo: UIView!
    @IBOutlet weak var view4_1: UIView!
    @IBOutlet weak var img4_1: ZoomImageView!
    @IBOutlet weak var btn4_1: UIButton!
    @IBOutlet weak var view4_2: UIView!
    @IBOutlet weak var img4_2: ZoomImageView!
    @IBOutlet weak var btn4_2: UIButton!
    @IBOutlet weak var view4_3: UIView!
    @IBOutlet weak var img4_3: ZoomImageView!
    @IBOutlet weak var btn4_3: UIButton!
    @IBOutlet weak var view4_4: UIView!
    @IBOutlet weak var img4_4: ZoomImageView!
    @IBOutlet weak var btn4_4: UIButton!
    
    @IBOutlet weak var view5Photo: UIView!
    @IBOutlet weak var view5_1: UIView!
    @IBOutlet weak var img5_1: ZoomImageView!
    @IBOutlet weak var btn5_1: UIButton!
    @IBOutlet weak var view5_2: UIView!
    @IBOutlet weak var img5_2: ZoomImageView!
    @IBOutlet weak var btn5_2: UIButton!
    @IBOutlet weak var view5_3: UIView!
    @IBOutlet weak var img5_3: ZoomImageView!
    @IBOutlet weak var btn5_3: UIButton!
    @IBOutlet weak var view5_4: UIView!
    @IBOutlet weak var img5_4: ZoomImageView!
    @IBOutlet weak var btn5_4: UIButton!
    @IBOutlet weak var view5_5: UIView!
    @IBOutlet weak var img5_5: ZoomImageView!
    @IBOutlet weak var btn5_5: UIButton!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_ADS_SHOW == true {
            loadInterstitial()
            if let adUnitID = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID
                bannerView.rootViewController = self
                bannerView.load(GADRequest())
                bannerView.delegate = self
                bannerView.isHidden = false
            } else {
                print("No ad unit ID found in UserDefaults")
            }
        }
        
        imagePicker.delegate = self
        imgFX.isHidden = true
        
        viewSinglePhoto.isHidden = true
        viewTriangleShape.isHidden = true
        view1Photo.isHidden = true
        view2Photo.isHidden = true
        view3Photo.isHidden = true
        view4Photo.isHidden = true
        view5Photo.isHidden = true
        
        viewShapes.isHidden = true
        viewTextEditor.isHidden = true
        viewAlign.isHidden = true
        viewColorPicker.isHidden = true
        
        for item in viewShapes.subviews{
            if item is UICollectionView{
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
        viewMain.objselection = self
        
        if objType == 1 {
            lblMainTitle.text = "GRID"
            setframe(objIndex)
        } else if objType == 2 {
            lblMainTitle.text = "EDIT"
            setSingleFrame()
        }
        
        if objType == 1 {
            for index in 0..<arrOfTotalImg.count{
                let img = arrOfTotalImg[index]
                EditScrollView(img)
            }
        } else if objType == 2 {
            EditSingleView(imgValue)
        }
        
        if arrOfTotalImg.count > 0 {
            for item in viewMain.subviews{
                if item is UIView{
                    for i in item.subviews{
                        if i is UIView{
                            for j in i.subviews{
                                if j is ZoomImageView{
                                    let scr: ZoomImageView = j as! ZoomImageView
                                    scr.image = UIImage(named: "ic_add_text")
                                    scr.tintColor = UIColor.black
                                    scr.backgroundColor = UIColor.lightGray
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func EditSingleView(_ img : UIImage){
        imgSingle.image = img
        imgSingle.zoomMode = .fill
    }
    func EditScrollView(_ img : UIImage){
        if objType == 1{
            for item in viewMain.subviews{
                if item is UIView{
                    for i in item.subviews{
                        if i is UIView{
                            for j in i.subviews{
                                if j is ZoomImageView{
                                    let scr: ZoomImageView = j as! ZoomImageView
                                    for index in 0..<arrOfTotalImg.count{
                                        if index == 0{
                                            if img == arrOfTotalImg[0]{
                                                if j == imgTriangle || j == img1_1 || j == img2_1 || j == img3_1 || j == img4_1 || j == img5_1{
                                                    self.setImageScroll(scr, img)
                                                }
                                            }
                                        }else if index == 1{
                                            if img == arrOfTotalImg[1]{
                                                if j == img1_2 || j == img2_2 || j == img3_2 || j == img4_2 || j == img5_2{
                                                    self.setImageScroll(scr, img)
                                                }
                                            }
                                        }else if index == 2 {
                                            if img == arrOfTotalImg[2]{
                                                if j == img3_3 || j == img4_3 || j == img5_3 {
                                                    self.setImageScroll(scr, img)
                                                }
                                            }
                                        }else if index == 3{
                                            if img == arrOfTotalImg[3]{
                                                if j == img4_4 || j == img5_4{
                                                    self.setImageScroll(scr, img)
                                                }
                                            }
                                        }else if index == 4 {
                                            if img == arrOfTotalImg[4]{
                                                if j == img5_5{
                                                    self.setImageScroll(scr, img)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setImageScroll(_ scroll : ZoomImageView, _ img : UIImage){
        scroll.image = img
        scroll.zoomMode = .fill
    }
    override func viewWillAppear(_ animated: Bool) {
        if IS_ADS_SHOW == true {
        TrigerInterstitial()
        }
        Analytics.logEvent("ImageEDITViewcontroller_enter", parameters: [
            "params": "purchase_screen_enter"
        ])
        if objPickImage == 0{
            for index in 0..<arrOfTotalImg.count{
                let img = arrOfTotalImg[index]
                EditScrollView(img)
            }
        }else if objPickImage == 1 || objPickImage == 2 || objPickImage == 3 || objPickImage == 4 || objPickImage == 5 || objPickImage == 6 || objPickImage == 7 || objPickImage == 8 || objPickImage == 9 || objPickImage == 10 || objPickImage == 11 || objPickImage == 12 || objPickImage == 13 || objPickImage == 14 || objPickImage == 15 || objPickImage == 16 || objPickImage == 17 {
            for index in 0..<arrOfTotalImg.count{
                let img = arrOfTotalImg[index]
                EditScrollView(img)
                isImageEmpty = false
                btnFilter.isHidden = false
                setFrameButton()
            }
        }
    }
 
    //MARK:- Button Action Zone
    @IBAction func btnFilterAction(_ sender: Any) {
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
        if btnFlipV.isSelected == true{
        }else{
            if objPickImage == 1 {
                if imgTriangle.transform == value2{
                    imgTriangle.transform = val
                }else{
                    imgTriangle.transform = value2
                }
            }else if objPickImage == 2{
                if img1_1.transform == value2{
                    img1_1.transform = val
                }else{
                    img1_1.transform = value2
                }
            }else if objPickImage == 3{
                if img1_2.transform == value2{
                    img1_2.transform = val
                }else{
                    img1_2.transform = value2
                }
            }
            else if objPickImage == 4{
                if img2_1.transform == value2{
                    img2_1.transform = val
                }else{
                    img2_1.transform = value2
                }
            }else if objPickImage == 5{
                if img2_2.transform == value2{
                    img2_2.transform = val
                }else{
                    img2_2.transform = value2
                }
            }else if objPickImage == 6{
                if img3_1.transform == value2{
                    img3_1.transform = val
                }else{
                    img3_1.transform = value2
                }
            }else if objPickImage == 7{
                if img3_2.transform == value2{
                    img3_2.transform = val
                }else{
                    img3_2.transform = value2
                }
            }else if objPickImage == 8{
                if img3_3.transform == value2{
                    img3_3.transform = val
                }else{
                    img3_3.transform = value2
                }
            }else if objPickImage == 9{
                if img4_1.transform == value2{
                    img4_1.transform = val
                }else{
                    img4_1.transform = value2
                }
            }else if objPickImage == 10{
                if img4_2.transform == value2{
                    img4_2.transform = val
                }else{
                    img4_2.transform = value2
                }
            }else if objPickImage == 11{
                if img4_3.transform == value2{
                    img4_3.transform = val
                }else{
                    img4_3.transform = value2
                }
            }else if objPickImage == 12{
                if img4_4.transform == value2{
                    img4_4.transform = val
                }else{
                    img4_4.transform = value2
                }
            }else if objPickImage == 13{
                if img5_1.transform == value2{
                    img5_1.transform = val
                }else{
                    img5_1.transform = value2
                }
            }else if objPickImage == 14{
                if img5_2.transform == value2{
                    img5_2.transform = val
                }else{
                    img5_2.transform = value2
                }
            }else if objPickImage == 15{
                if img5_3.transform == value2{
                    img5_3.transform = val
                }else{
                    img5_3.transform = value2
                }
            }else if objPickImage == 16{
                if img5_4.transform == value2{
                    img5_4.transform = val
                }else{
                    img5_4.transform = value2
                }
            }else if objPickImage == 17{
                if img5_5.transform == value2{
                    img5_5.transform = val
                }else{
                    img5_5.transform = value2
                }
            }
        }
    }
    @IBAction func btnFlipHAction(_ sender: Any) {
        if btnFlipH.isSelected == true{
        }else{
            if objPickImage == 1{
                if imgTriangle.transform == value1{
                    imgTriangle.transform = val
                }else{
                    imgTriangle.transform = value1
                }
            }else if objPickImage == 2{
                if img1_1.transform == value1{
                    img1_1.transform = val
                }else{
                    img1_1.transform = value1
                }
            }else if objPickImage == 3{
                if img1_2.transform == value1{
                    img1_2.transform = val
                }else{
                    img1_2.transform = value1
                }
            }
            else if objPickImage == 4{
                if img2_1.transform == value1{
                    img2_1.transform = val
                }else{
                    img2_1.transform = value1
                }
            }else if objPickImage == 5{
                if img2_2.transform == value1{
                    img2_2.transform = val
                }else{
                    img2_2.transform = value1
                }
            }else if objPickImage == 6{
                if img3_1.transform == value1{
                    img3_1.transform = val
                }else{
                    img3_1.transform = value1
                }
            }else if objPickImage == 7{
                if img3_2.transform == value1{
                    img3_2.transform = val
                }else{
                    img3_2.transform = value1
                }
            }else if objPickImage == 8{
                if img3_3.transform == value1{
                    img3_3.transform = val
                }else{
                    img3_3.transform = value1
                }
            }else if objPickImage == 9{
                if img4_1.transform == value1{
                    img4_1.transform = val
                }else{
                    img4_1.transform = value1
                }
            }else if objPickImage == 10{
                if img4_2.transform == value1{
                    img4_2.transform = val
                }else{
                    img4_2.transform = value1
                }
            }else if objPickImage == 11{
                if img4_3.transform == value1{
                    img4_3.transform = val
                }else{
                    img4_3.transform = value1
                }
            }else if objPickImage == 12{
                if img4_4.transform == value1{
                    img4_4.transform = val
                }else{
                    img4_4.transform = value1
                }
            }else if objPickImage == 13{
                if img5_1.transform == value1{
                    img5_1.transform = val
                }else{
                    img5_1.transform = value1
                }
            }else if objPickImage == 14{
                if img5_2.transform == value1{
                    img5_2.transform = val
                }else{
                    img5_2.transform = value1
                }
            }else if objPickImage == 15{
                if img5_3.transform == value1{
                    img5_3.transform = val
                }else{
                    img5_3.transform = value1
                }
            }else if objPickImage == 16{
                if img5_4.transform == value1{
                    img5_4.transform = val
                }else{
                    img5_4.transform = value1
                }
            }else if objPickImage == 17{
                if img5_5.transform == value1{
                    img5_5.transform = val
                }else{
                    img5_5.transform = value1
                }
            }
        }
    }
    func setFrameButton(){
        let value  = ((viewReplaceImg.frame.width) - (btnFlipV.frame.width * 9)) / 2
        let width = btnFlipV.frame.width * 2
        btnFlipV.frame = CGRect(x: value , y: 13, width: 35, height: 35)
        btnFlipH.frame = CGRect(x: value + width, y: 13, width: 35, height: 35)
        btnReplace.frame = CGRect(x: btnFlipH.frame.origin.x + width, y: 13, width: 35, height: 35)
        btnFilter.frame = CGRect(x: btnReplace.frame.origin.x + width, y: 13, width: 35, height: 35)
        btnDown3.frame = CGRect(x: btnFilter.frame.origin.x + width, y: 13, width: 35, height: 35)
    
    }
    func setFrameButton1(){
        let value = ((viewReplaceImg.frame.width) - ((btnFlipV.frame.width + 5 ) * 7)) / 2
        let width = (btnFlipV.frame.width + 5) * 2
        btnFlipV.frame = CGRect(x: value, y: 13, width: 35, height: 35)
        btnFlipH.frame = CGRect(x: value + width, y: 13, width: 35, height: 35)
        btnReplace.frame = CGRect(x: btnFlipH.frame.origin.x + width, y: 13, width: 35, height: 35)
        btnDown3.frame = CGRect(x: btnReplace.frame.origin.x + width, y: 13, width: 35, height: 35)
    }
    
    @IBAction func btnDown3Action(_ sender: Any) {
        for item in self.viewMain.subviews{
            if item is UIView{
                for i in item.subviews{
                    if i is UIView{
                        for j in i.subviews{
                            if j is UIButton{
                                let btn: UIButton = j as! UIButton
                                btn.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
            }
        }
        viewReplaceImg.isHidden = true
        viewMainItems.isHidden = false
        setView(view: viewMainItems)
    }
    @IBAction func btnTriangleAction(_ sender: Any) {
        if btnTriangle.isSelected == true{
        }else if btnTriangle.isSelected == false{
            btnTriangle.isUserInteractionEnabled = false
            btnSelection(1)
            if let img = imgTriangle.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn1_1Action(_ sender: UIButton) {
        if btn1_1.isSelected == true{
        }else if btn1_1.isSelected == false{
            btn1_1.isUserInteractionEnabled = false
            btnSelection(2)
            if let img = img1_1.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    
    @IBAction func btn1_2Action(_ sender: Any) {
        if btn1_2.isSelected == true{
        }else if btn1_2.isSelected == false{
            btn1_2.isUserInteractionEnabled = false
            btnSelection(3)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img1_2.image{
                 imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    
    @IBAction func btn2_1Action(_ sender: UIButton) {
        if btn2_1.isSelected == true{
        }else{
            btn2_1.isUserInteractionEnabled = false
            btnSelection(4)
            if let img = img2_1.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn2_2Action(_ sender: UIButton) {
        if btn2_2.isSelected == true{
        }else{
            btn2_2.isUserInteractionEnabled = false
            btnSelection(5)
            setFrameButton1()
            btnFilter.isHidden = true
            if let img = img2_2.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn3_1Action(_ sender: UIButton) {
        if btn3_1.isSelected == true{
        }else{
            btn3_1.isUserInteractionEnabled = false
            btnSelection(6)
            if let img = img3_1.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn3_2Action(_ sender: UIButton) {
        if btn3_2.isSelected == true{
        }else{
            btn3_2.isUserInteractionEnabled = false
            btnSelection(7)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img3_2.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()

                }
            }
        }
    }
    @IBAction func btn3_3Action(_ sender: UIButton) {
        if btn3_3.isSelected == true{
        }else{
            btn3_3.isUserInteractionEnabled = false
            btnSelection(8)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img3_3.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn4_1Action(_ sender: UIButton) {
        if btn4_1.isSelected == true{
        }else{
            btn4_1.isUserInteractionEnabled = false
            btnSelection(9)
            if let img = img4_1.image{
               imgFilter = img
               if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn4_2Action(_ sender: UIButton) {
        if btn4_2.isSelected == true{
        }else{
            btn4_2.isUserInteractionEnabled = false
            btnSelection(10)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img4_2.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn4_3Action(_ sender: UIButton) {
        if btn4_3.isSelected == true{
        }else{
            btn4_3.isUserInteractionEnabled = false
            btnSelection(11)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img4_3.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn4_4Action(_ sender: UIButton) {
        if btn4_4.isSelected == true{
        }else{
            btn4_4.isUserInteractionEnabled = false
            btnSelection(12)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img4_4.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn5_1Action(_ sender: UIButton) {
        if btn5_1.isSelected == true{
        }else{
            btn5_1.isUserInteractionEnabled = false
            btnSelection(13)
            if let img = img5_1.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn5_2Action(_ sender: UIButton) {
        if btn5_2.isSelected == true{
        }else{
            btn5_2.isUserInteractionEnabled = false
            btnSelection(14)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img5_2.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    
    @IBAction func btn5_3Action(_ sender: UIButton) {
        if btn5_3.isSelected == true{
        }else{
            btn5_3.isUserInteractionEnabled = false
             btnSelection(15)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img5_3.image{
               imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    
    @IBAction func btn5_4Action(_ sender: UIButton) {
        if btn5_4.isSelected == true{
        }else{
            btn5_4.isUserInteractionEnabled = false
            btnSelection(16)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img5_4.image{
               imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    @IBAction func btn5_5Action(_ sender: UIButton) {
        if btn5_5.isSelected == true{
        }else{
            btn5_5.isUserInteractionEnabled = false
            btnSelection(17)
            btnFilter.isHidden = true
            setFrameButton1()
            if let img = img5_5.image{
                imgFilter = img
                if let index = arrOfTotalImg.firstIndex(of: img){
                    imgIndex = index
                    isImageEmpty = true
                    btnFilter.isHidden = false
                    setFrameButton()
                }
            }
        }
    }
    func btnSelection(_ obj : Int){
        objPickImage = obj
        viewReplaceImg.isHidden = false
        setView(view: viewReplaceImg)
        viewMainItems.isHidden = true
        viewShapes.isHidden = true
        viewTextEditor.isHidden = true
    }
    @IBAction func btnReplaceAction(_ sender: UIButton) {
        openGallary()
        isSelectGallery = true
    }
    @IBAction func btnBackAction(_ sender: Any) {
        if objType == 1{
            self.objpresentPhotoVC.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }else if objType == 2{
            self.objpresentPhotoVC.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.selectedStickerView?.showEditing = false
    }
    @IBAction func btnSaveAction(_ sender: Any) {
        SVProgressHUD.show()
        DispatchQueue.main.async {
            self.selectedStickerView?.showEditing = false
            Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
        }
    }
    @IBAction func btnDownAction(_ sender: Any) {
        self.viewShapes.isHidden = true
        for item in viewMain.subviews {
            if item is UIView{
                for i in item.subviews{
                    if i is UIView{
                        for j in i.subviews{
                            if j is UIButton{
                                let btn : UIButton = j as! UIButton
                                btn.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
            }
        }
        viewReplaceImg.isHidden = true
        setView(view: self.viewMainItems)
        self.viewMainItems.isHidden = false
    }
    @IBAction func btnKeyboardAction(_ sender: Any) {
        let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
        obj.objSelection = 2
        obj.objImg = self
        self.present(obj, animated: true, completion: nil)
    }
    @IBAction func btnFontStyleAction(_ sender: Any) {
        self.objSelectTxtValue = 2
        viewAlign.isHidden = true
        viewColorPicker.isHidden = true
        tblFontStyle.isHidden = false
        tblFontStyle.reloadData()
    }
    @IBAction func btnColorAction(_ sender: Any) {
        viewColorPicker.isHidden = false
        viewAlign.isHidden = true
        setColor()
    }
    @IBAction func btnAlignAction(_ sender: Any) {
        viewAlign.isHidden = false
        tblFontStyle.isHidden = true
        viewColorPicker.isHidden = true
    }
    @IBAction func btnAddTextAction(_ sender: Any) {
        let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
        obj.objSelection = 3
        obj.objImg = self
        self.present(obj, animated: true, completion: nil)
    }
    @IBAction func btnDown1Action(_ sender: Any) {
        selectedStickerView?.showEditing = false
        viewMain.currentlyEditingLabel.hideEditingHandlers()
        viewTextEditor.isHidden = true
        viewReplaceImg.isHidden = true
        for item in viewMain.subviews {
            if item is UIView{
                for i in item.subviews{
                    if i is UIView{
                        for j in i.subviews{
                            if j is UIButton{
                                let btn : UIButton = j as! UIButton
                                btn.isUserInteractionEnabled = true
                            }
                        }
                    }
                }
            }
        }
        setView(view: viewMainItems)
        viewMainItems.isHidden = false
    }
    @IBAction func btnLeftAction(_ sender: Any) {
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .left
    }
    @IBAction func btnCenterAction(_ sender: Any) {
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .center
    }
    @IBAction func btnRightAction(_ sender: Any) {
        viewMain.currentlyEditingLabel.labelTextView?.textAlignment = .right
    }
    @IBAction func sliderOpacityAction(_ sender: UISlider) {
        let currentValue = CGFloat(sender.value)
        viewMain.currentlyEditingLabel.labelTextView?.alpha = currentValue
    }
   
    
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
    
    //MARK:- CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if objType == 1{
            if collectionView == self.mainItemsCV {
                return arrOfMain.count
            }
            else if collectionView == ShapeCV{
                return 59
            }else if collectionView == BackGroundCV{
                return 19
            }else if collectionView == self.FilterCV{
                return arrOfFilter.count
            }else if collectionView == self.FxCV{
                return arrOfFx.count
            }else {
                return 0
            }
        }else if objType == 2{
            if collectionView == self.mainItemsCV {
                return arrOfSingleMain.count
            }else if collectionView == self.FilterCV{
                return arrOfFilter.count
            }else if collectionView == self.FxCV{
                return arrOfFx.count
            }else {
                return 0
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.mainItemsCV{
            let cell: SelectItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectItemCell", for: indexPath) as! SelectItemCell
            if cell.btnItem == (cell.viewWithTag(10) as? UIButton) {
                if objType == 1{
                    cell.imgItem.image = UIImage(named: arrOfMain[indexPath.row])
                    cell.btnItem.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == 0{
                            btn.isEnabled = true
                            self.viewShapes.isHidden = false
                            self.lblTitle.text = "Layouts"
                            self.BackGroundCV.isHidden = true
                            self.FilterCV.isHidden = true
                            self.ShapeCV.isHidden = false
                            self.FxCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.viewMainItems.isHidden = true
                        }else if indexPath.row == 1{
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            self.FxCV.isHidden = true
                            self.BackGroundCV.isHidden = false
                            self.FilterCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.lblTitle.text = "BackGrounds"
                            self.viewMainItems.isHidden = true
                        }else if indexPath.row == 2{
                            btn.isEnabled = true
                            let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
                            obj.objImg = self
                            obj.objSelection = 1
                            self.present(obj, animated: true, completion: nil)
                        }else if indexPath.row == 3{
                            btn.isEnabled = true
                            let obj : StickersVC = self.storyboard?.instantiateViewController(withIdentifier: "StickersVC") as! StickersVC
                            obj.objImage = self
                            obj.objStickerSelecion = 1
                            self.navigationController?.pushViewController(obj, animated: true)
                        }else if indexPath.row == 4{
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
                }else if objType == 2{
                    cell.imgItem.image = UIImage(named: arrOfSingleMain[indexPath.row])
                    cell.btnItem.mk_addTapHandlerIO { (btn) in
                        btn.isEnabled = true
                        if indexPath.row == 0{
                            btn.isEnabled = true
                            let obj : CurrentTextVC = self.storyboard?.instantiateViewController(withIdentifier: "CurrentTextVC") as! CurrentTextVC
                            obj.objImg = self
                            obj.objSelection = 1
                            self.present(obj, animated: true, completion: nil)
                        }else if indexPath.row == 1{
                            btn.isEnabled = true
                            let obj : StickersVC = self.storyboard?.instantiateViewController(withIdentifier: "StickersVC") as! StickersVC
                            obj.objImage = self
                            obj.objStickerSelecion = 1
                            self.navigationController?.pushViewController(obj, animated: true)
                        }else if indexPath.row == 2{
                            btn.isEnabled = true
                            self.viewShapes.isHidden = false
                            self.ShapeCV.isHidden = true
                            setView(view: self.viewShapes)
                            self.FilterCV.isHidden = true
                            self.BackGroundCV.isHidden = true
                            self.FxCV.isHidden = false
                            self.lblTitle.text = "Textures"
                            self.viewMainItems.isHidden = true
                        }else if indexPath.row == 3{
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
        }else if collectionView == ShapeCV{
            let cell : StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
            cell.imgSelection.image = UIImage(named: "\(indexPath.row+1)")
            if cell.btnImage == (cell.viewWithTag(5) as? UIButton){
                cell.btnImage.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.imgFX.isHidden = false
                    self.imgFX.isUserInteractionEnabled = false
                    
                    self.view1Photo.isHidden = true
                    self.view2Photo.isHidden = true
                    self.view3Photo.isHidden = true
                    self.view4Photo.isHidden = true
                    self.view5Photo.isHidden = true
                    if indexPath.row == arrOfIndex[indexPath.row]{
                        let index = indexPath.row
                        for item in self.viewMain.subviews{
                            if item is UIView{
                                for i in item.subviews{
                                    if i is UIView{
                                        for j in i.subviews{
                                            if j is UIButton{
                                                let btn: UIButton = j as! UIButton
                                                btn.isUserInteractionEnabled = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        self.setframe(index)
                    }
                }
            }
            return cell
        }else if collectionView == BackGroundCV{
            let cell: FramesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FramesCell", for: indexPath) as! FramesCell
            
            if cell.btnFrame == (cell.viewWithTag(15) as? UIButton) {
                cell.imgFrame.image = UIImage(named: "\(indexPath.row+1)_BG")
                cell.btnFrame.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.imgFX.isHidden = false
                    self.imgFX.isUserInteractionEnabled = false
                    self.imgBackground.isHidden = false
                    let img = UIImage(named: "\(indexPath.row+1)_BG")
                    if indexPath.row == arrOfIndex[indexPath.row]{
                        self.imgBackground.image = img
                        self.imgBackground.isUserInteractionEnabled = false
                    }
                }
            }
            return cell
        }else if collectionView == self.FxCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FramesCell", for: indexPath) as! FramesCell
            if cell.btnFrame == (cell.viewWithTag(15) as? UIButton) {
                cell.imgFrame.image = UIImage(named: arrOfFx[indexPath.row])
                cell.imgCommon.image = UIImage(named: "sample")
                cell.btnFrame.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    self.imgFX.isHidden = false
                    
                    let img = UIImage(named: arrOfFx[indexPath.row])
                    if indexPath.row == arrOfIndex[indexPath.row]{
                        self.imgFX.image = img
                        self.imgFX.isUserInteractionEnabled = false
                    }
                }
            }
            return cell
        }else if collectionView == self.FilterCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell

            if cell.btnFilters == (cell.viewWithTag(20) as? UIButton) {
                
                cell.imgCommon.image = UIImage(named: "sample")
                cell.lblTitles.text = arrOfFilter[indexPath.row]
                
                cell.btnFilters.mk_addTapHandlerIO { (btn) in
                    btn.isEnabled = true
                    if self.objType == 1{
                        if self.objPickImage == 1 || self.objPickImage == 2 || self.objPickImage == 3 || self.objPickImage == 4 || self.objPickImage == 5 || self.objPickImage == 6 || self.objPickImage == 7 || self.objPickImage == 8 || self.objPickImage == 9 || self.objPickImage == 10 || self.objPickImage == 11 || self.objPickImage == 12 || self.objPickImage == 13 || self.objPickImage == 14 || self.objPickImage == 15 || self.objPickImage == 16 || self.objPickImage == 17{
                            
                            if indexPath.row == 0{
                                if self.objPickImage == 0{
                                    //self.EditScrollView()
                                }
                            }else if indexPath.row == 1{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectChrome")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 2{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectFade")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 3{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectInstant")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 4{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectMono")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 5{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectNoir")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 6{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectProcess")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 7{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectTonal")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 8{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIPhotoEffectTransfer")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 9{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CILinearToSRGBToneCurve")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 10{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CISepiaTone")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 11{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIGaussianBlur")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 12{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CIExposureAdjust", key: kCIInputEVKey, value: 1)
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 13{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CIVignette", key: kCIInputIntensityKey, value: 5)
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 14{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 =  getScannedImage(inputImage: self.imgFilter)
                                    self.replaceImg(img1!)
                                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 15{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = simpleBlurFilterExample(myImage: self.imgFilter, filter: "CISharpenLuminance", key: kCIInputSharpnessKey, value: 10)
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }else if indexPath.row == 16{
                                SVProgressHUD.show()
                                DispatchQueue.main.async {
                                    let img1 = applyFilter(image: self.imgFilter, filterName: "CIColorInvert")
                                    print(self.imgIndex)
                                    self.arrOfTotalImg[self.imgIndex] = img1
                                    self.replaceImg(img1)
                                    
                                    for index in 0..<self.arrOfTotalImg.count{
                                        let img = self.arrOfTotalImg[index]
                                        self.EditScrollView(img)
                                    }
                                    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                                }
                            }
                        }
                    }else if self.objType == 2{
                        if indexPath.row == 0{
                            self.EditScrollView(self.imgValue)

                        }else if indexPath.row == 1{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectChrome")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 2{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectFade")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 3{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectInstant")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 4{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectMono")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 5{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectNoir")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 6{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectProcess")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 7{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectTonal")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 8{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIPhotoEffectTransfer")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 9{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CILinearToSRGBToneCurve")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 10{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CISepiaTone")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 11{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIGaussianBlur")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 12{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = simpleBlurFilterExample(myImage: self.imgValue, filter: "CIExposureAdjust", key: kCIInputEVKey, value: 1)
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 13{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = simpleBlurFilterExample(myImage: self.imgValue, filter: "CIVignette", key: kCIInputIntensityKey, value: 5)
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 14{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 =  getScannedImage(inputImage: self.imgValue)
                                self.EditSingleView(img1!)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 15{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = simpleBlurFilterExample(myImage: self.imgValue, filter: "CISharpenLuminance", key: kCIInputSharpnessKey, value: 10)
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }else if indexPath.row == 16{
                            SVProgressHUD.show()
                            DispatchQueue.main.async {
                                let img1 = applyFilter(image: self.imgValue, filterName: "CIColorInvert")
                                self.EditSingleView(img1)
                                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update1), userInfo: nil, repeats: false)
                            }
                        }
                
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
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
    
    func setColor(){
        colorPicker.delegate = self
        colorPicker.layoutDelegate = self
        colorPicker.isSelectedColorTappable = true
        colorPicker.style = .circle
        colorPicker.selectionStyle = .check
        colorPicker.backgroundColor = .clear
    }
    
    func replaceImg(_ img : UIImage){
        if objPickImage == 1 {
            for item in viewTriangle.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 2 {
            for item in view1_1.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 3{
            for item in view1_2.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 4{
            for item in view2_1.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 5{
            for item in view2_2.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 6{
            for item in view3_1.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 7{
            for item in view3_2.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 8{
            for item in view3_3.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 9{
            for item in view4_1.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 10{
            for item in view4_2.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 11{
            for item in view4_3.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 12{
            for item in view4_4.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 13{
            for item in view5_1.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 14{
            for item in view5_2.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 15{
            for item in view5_3.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 16{
            for item in view5_4.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }else if objPickImage == 17{
            for item in view5_5.subviews{
                if item is ZoomImageView{
                    let scr: ZoomImageView = item as! ZoomImageView
                    self.setImageScroll(scr, img)
                }
            }
        }
    }
    
    func setStickers(_ img : UIImage){
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
    
    func addTextLabel(_ txt : String){
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
//        viewMain.currentlyEditingLabel.objViewHidden = self
        self.dismiss(animated: true, completion: nil)
    }
    @objc func update1() {
        SVProgressHUD.dismiss()
    }
    func setSingleFrame(){
        viewSinglePhoto.isHidden = false
        imgSingleBackground.image = imgValue
    }
    func setframe(_ index : Int){
        let value1 = view.frame.size.width
        let value2 = view2Photo.frame.size.height
        let value3 = view.frame.size.width/2
        let value4 = view2Photo.frame.size.height/2
        
        viewTriangleShape.isHidden = true
        view1Photo.isHidden = true
        view2Photo.isHidden = true
        view3Photo.isHidden = true
        view4Photo.isHidden = true
        view5Photo.isHidden = true
        
        if index == 0{
            self.view1Photo.isHidden = false
            self.view1_1.isHidden = false
            btn1_1.isHidden = false
            self.view1_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            self.img1_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2-6)
            btn1_1.frame = self.img1_1.frame
            
            
            self.view1_2.frame = CGRect(x: value2/3, y: value2/3, width: value4, height: value4)
            self.img1_2.frame = CGRect(x: 0, y: 0, width: 200, height:  150)
            btn1_2.frame = self.img1_2.frame
            let aPath = UIBezierPath()
            aPath.move(to: CGPoint(x: 90, y: 0))
            aPath.addLine(to: CGPoint(x: 180, y: 40.0))
            aPath.addLine(to: CGPoint(x: 140, y: 120))
            aPath.addLine(to: CGPoint(x: 40.0, y: 120))
            aPath.addLine(to: CGPoint(x: 0, y: 40.0))
            aPath.close()
            
            let shape = CAShapeLayer()
            shape.path = aPath.cgPath
            shape.strokeColor = UIColor.white.cgColor
            shape.lineWidth = 0
            
            self.view1_2.layer.mask = shape
        }else if index == 1{
            self.viewTriangleShape.isHidden = false
            self.viewTriangle.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            self.imgTriangle.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            btnTriangle.frame = self.imgTriangle.frame
            
            let aPath1 = UIBezierPath()
            aPath1.move(to: CGPoint(x: 0, y: 0))
            aPath1.addLine(to: CGPoint(x: value1, y: value2))
            aPath1.addLine(to: CGPoint(x: value1, y: 0))
            aPath1.addLine(to: CGPoint(x: value1, y: 0))
            aPath1.addLine(to: CGPoint(x: 0, y: value2))
            aPath1.close()
            
            let shape1 = CAShapeLayer()
            shape1.path = aPath1.cgPath
            shape1.strokeColor = UIColor.white.cgColor
            shape1.lineWidth = 0
            self.viewTriangle.layer.mask = shape1
        }else if index == 2{
            self.viewTriangleShape.isHidden = false
           
            self.viewTriangle.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            self.imgTriangle.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            btnTriangle.frame = self.imgTriangle.frame
            let aPath1 = UIBezierPath()
            aPath1.move(to: CGPoint(x: 0, y: 0))
            aPath1.addLine(to: CGPoint(x: value1, y: value2))
            aPath1.addLine(to: CGPoint(x: 0, y: value2))
            aPath1.addLine(to: CGPoint(x: value1, y: 0))
            aPath1.addLine(to: CGPoint(x: value1, y: 0))
            aPath1.close()
            
            let shape1 = CAShapeLayer()
            shape1.path = aPath1.cgPath
            shape1.strokeColor = UIColor.white.cgColor
            shape1.lineWidth = 0
            self.viewTriangle.layer.mask = shape1
        }else if index == 3{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.white
            self.view2_1.frame = CGRect(x: 0 , y: 0, width: value1, height: value2)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2-6)
            self.view2_2.frame = CGRect(x: value3+10, y: value4+10, width: value4-50, height: value4-50)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value4-50-6, height: value4-50-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 4{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view2_2.frame = CGRect(x: value3, y: 0, width: value3, height: value2)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 5{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value1, height: value4)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            self.view2_2.frame = CGRect(x: 0, y: value4, width: value1, height: value4)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 6{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value1, height: (value2/3))
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: (value2/3)-6)
            self.view2_2.frame = CGRect(x: 0, y: (value2/3), width: value1, height: (value2/3)+(value2/3))
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: (value2/3)+(value2/3)-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 7{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value1, height: (value2/3)+(value2/3))
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: (value2/3)+(value2/3)-6)
            self.view2_2.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1, height: value2/3)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 8{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view2_2.frame = CGRect(x: value1/3, y: 0, width: (value1/3)+(value1/3), height: value2)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 9{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: value2)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2-6)
            self.view2_2.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 10{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value3-6 , height: value4-6)
            self.view2_2.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img2_2.frame = CGRect(x: 3, y:3, width: value3-6, height: value4-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 11{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: value2/3, width: value3, height: (value2/3)+(value2/3))
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: (value2/3)+(value2/3)-6)
            self.view2_2.frame = CGRect(x: value3, y: 0, width: value3, height: (value2/3)+(value2/3))
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: (value2/3)+(value2/3)-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 12{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: value4)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value4-6)
            self.view2_2.frame = CGRect(x: value1/3, y: value4, width: (value1/3)+(value1/3), height: value4)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value4-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 13{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: value2/4, width: value3, height: value4)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view2_2.frame = CGRect(x: value3, y: value2/4, width: value3, height: value4)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 14{
            self.view2Photo.isHidden = false
            self.view2_2.backgroundColor = UIColor.clear
            
            self.view2_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img2_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view2_2.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img2_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            
            btn2_1.frame = self.img2_1.frame
            btn2_2.frame = self.img2_2.frame
        }else if index == 15{
            self.view3Photo.isHidden = false
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3, y: 0, width: value3, height: value2)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view3_3.backgroundColor = UIColor.white
            self.view3_3.frame = CGRect(x: value3/2 , y: value4/2, width: value3 , height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 16{
            self.view3Photo.isHidden = false
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1, height: value4)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            self.view3_2.frame = CGRect(x: 0, y: value4+3, width: value1, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            self.view3_3.backgroundColor = UIColor.white
            self.view3_3.frame = CGRect(x: value3/2, y: value4/2, width: value3 , height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
    
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 17{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value2)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view3_3.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
          
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 18{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2/3)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view3_2.frame = CGRect(x: 0, y: value2/3, width: value1, height: value2/3)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view3_3.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1, height:  value2/3)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1-6, height:  value2/3-6)
            
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 19{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1, height: value4)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            self.view3_2.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_3.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 20{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_3.frame = CGRect(x: 0, y: value4, width: value1, height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1-6, height: value4-6)
            
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 21{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_3.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 22{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_2.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_3.frame = CGRect(x: value3, y: 0, width: value3, height: value2)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 23{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2/3)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view3_2.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view3_3.frame = CGRect(x: (value1/3)+(value1/3), y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 24{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2/3)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view3_2.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view3_3.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 25{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value4+50)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+50-6)
            self.view3_2.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value4+50)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+50-6)
            self.view3_3.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value4+50)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+50-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 26{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: value4-35, width: value1/3, height: value4+35)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+35-6)
            self.view3_2.frame = CGRect(x: value1/3, y: (value4-35)/2, width: value1/3, height: value4+35)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+35-6)
            self.view3_3.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value4+35)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4+35-6)
            
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
            
        }else if index == 27{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4-75)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-75-6)
            self.view3_3.frame = CGRect(x: value3, y: value4-75, width: value3, height: value4+75)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4+75-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 28{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3/2, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3/2-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3/2, y: 0, width: value3, height: value2)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view3_3.frame = CGRect(x: (value3)+(value3/2), y: 0, width: value3/2, height: value2)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3/2-6, height: value2-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 29{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_2.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view3_3.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 30{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.clear
            
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value3-50, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value3-50-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3-50, y: 0, width: value3+50, height: value4)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: value3+50-6, height: value4-6)
            self.view3_3.frame = CGRect(x: value3-50, y: value4, width: value3+50, height: value4)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: value3+50-6, height: value4-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 31{
            self.view3Photo.isHidden = false
            self.view3_3.backgroundColor = UIColor.white
            self.view3_2.backgroundColor = UIColor.white
            
            self.view3_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            self.img3_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2-6)
            self.view3_2.frame = CGRect(x: value3-119, y: value4-117, width: 150, height: 150)
            self.img3_2.frame = CGRect(x: 3, y: 3, width: 150-6, height: 150-6)
            self.view3_3.frame = CGRect(x: value3-61, y: value4-62, width: 150, height: 150)
            self.img3_3.frame = CGRect(x: 3, y: 3, width: 150-6, height: 150-6)
            btn3_1.frame = self.img3_1.frame
            btn3_2.frame = self.img3_2.frame
            btn3_3.frame = self.img3_3.frame
        }else if index == 32{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_3.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_4.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 33{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view4_2.frame = CGRect(x: value1/3, y: 0, width: (value1/3)+(value1/3), height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value4-6)
            self.view4_3.frame = CGRect(x: 0, y: value4, width: (value1/3)+(value1/3), height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value4-6)
            self.view4_4.frame = CGRect(x: (value1/3)+(value1/3), y: value4, width: value1/3, height: value4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 34{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2/3)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_2.frame = CGRect(x: value3, y: 0, width: value3, height: (value2/3)+(value2/3))
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: (value2/3)+(value2/3)-6)
            self.view4_3.frame = CGRect(x: 0, y:  value2/3, width: value3, height: (value2/3)+(value2/3))
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: (value2/3)+(value2/3)-6)
            self.view4_4.frame = CGRect(x: value3, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 35{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2-6)
            self.view4_2.frame = CGRect(x: value3, y: 0, width: value3, height: value2/3)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_3.frame = CGRect(x: value3, y: value2/3, width: value3, height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: value3, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 36{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1, height: value4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1, height: value4-6)
            self.view4_2.frame = CGRect(x: 0, y: value4, width: value1/3, height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view4_3.frame = CGRect(x: value1/3, y: value4, width: value1/3, height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view4_4.frame = CGRect(x: (value1/3)+(value1/3), y: value4, width: value1/3, height: value4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 37{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2/3)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view4_2.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value2/3)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view4_3.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: 0, y: value2/3, width: value1, height: (value2/3)+(value2/3))
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1-6, height: (value2/3)+(value2/3)-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 38{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: (value2/3)+(value2/3))
            self.img4_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: (value2/3)+(value2/3)-6)
            self.view4_2.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: (value2/3)+(value2/3))
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: (value2/3)+(value2/3)-6)
            self.view4_3.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: (value1/3)+(value1/3), height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: (value1/3)+(value1/3), y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 39{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3-75, height: value4-75)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-75-6, height: value4-75-6)
            self.view4_2.frame = CGRect(x: value3-75, y: 0, width: value3+75, height: value4-75)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3+75-6, height: value4-75-6)
            self.view4_3.frame = CGRect(x: 0, y: value4-75, width: value3-75, height: value4+75)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-75-6, height: value4+75-6)
            self.view4_4.frame = CGRect(x: value3-75, y: value4-75, width: value3+75, height: value4+75)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3+75-6, height: value4+75-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 40{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3-75, height: value2)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-75-6, height: value2-6)
            self.view4_2.frame = CGRect(x: value3-75, y: 0, width: value3+75, height: value4+75)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3+75-6, height: value4+75-6)
            self.view4_3.frame = CGRect(x: value3-75, y: value4+75, width: (value3+75)/2, height: value4-75)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: (value3+75)/2-6, height: value4-75-6)
            self.view4_4.frame = CGRect(x: (value3-75)+((value3+75)/2), y: value4+75, width: (value3+75)/2, height: value4-75)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: (value3+75)/2-6, height: value4-75-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 41{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2/3)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view4_2.frame = CGRect(x: 0, y: value2/3, width: value3, height: value2/3)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_3.frame = CGRect(x: value3, y: value2/3, width: value3, height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 42{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view4_2.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view4_3.frame = CGRect(x: value1/3, y: value4, width: value1/3, height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view4_4.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 43{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2/3)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_2.frame = CGRect(x: value3, y: 0, width: value3, height: value2/3)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_3.frame = CGRect(x: 0, y: value2/3, width: value1, height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 44{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2/3)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view4_2.frame = CGRect(x: 0, y: value2/3, width: value1, height: value2/3)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view4_3.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view4_4.frame = CGRect(x: value3, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 45{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1/4, height: value2)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2-6)
            self.view4_2.frame = CGRect(x: value1/4, y: 0, width: value1/4, height: value2)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2-6)
            self.view4_3.frame = CGRect(x: (value1/4)+(value1/4), y: 0, width: value1/4, height: value2)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2-6)
            self.view4_4.frame = CGRect(x: (value1/4)+(value1/4)+(value1/4), y: 0, width: value1/4, height: value2)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 46{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2/4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/4-6)
            self.view4_2.frame = CGRect(x: 0, y: value2/4, width: value1, height: value2/4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/4-6)
            self.view4_3.frame = CGRect(x: 0, y: (value2/4)+(value2/4), width: value1, height: value2/4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/4-6)
            self.view4_4.frame = CGRect(x: 0, y: (value2/4)+(value2/4)+(value2/4), width: value1, height: value2/4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/4-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 47{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: value4, width: value1/4, height: value4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value4-6)
            self.view4_2.frame = CGRect(x: value1/4, y: value4-75, width: value1/4, height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value4-6)
            self.view4_3.frame = CGRect(x: (value1/4)+(value1/4), y: value4-150, width: value1/4, height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value4-6)
            self.view4_4.frame = CGRect(x: (value1/4)+(value1/4)+(value1/4), y: 0, width: value1/4, height: value4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value4-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 48{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = true
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value1, height: value2)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2-6)
            self.view4_2.frame = CGRect(x: value3-157, y: value4-150, width: 150, height: 150)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: 150-6, height: 150-6)
            self.view4_3.frame = CGRect(x: value3-75, y: value4-75, width: 150, height: 150)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: 150-6, height: 150-6)
            self.view4_4.frame = CGRect(x:  value3+13, y: value4+3, width: 150, height: 150)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: 150-6, height: 150-6)
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 49{
            self.view4Photo.isHidden = false
            self.viewWhite.isHidden = false
            self.view4_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
            self.img4_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4)
            self.img4_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_3.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
            self.img4_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.view4_4.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
            self.img4_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
            self.viewWhite.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
            self.viewWhite.backgroundColor = UIColor.white
            btn4_1.frame = self.img4_1.frame
            btn4_2.frame = self.img4_2.frame
            btn4_3.frame = self.img4_3.frame
            btn4_4.frame = self.img4_4.frame
        }else if index == 50{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value1/3 , height: (value2/3)+(value2/3))
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value1/3-6 , height: (value2/3)+(value2/3)-6)
            self.view5_2.frame = CGRect(x: value1/3, y: 0, width: (value1/3)+(value1/3), height: (value2/3)+(value2/3))
            self.img5_2.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: (value2/3)+(value2/3)-6)
            self.view5_3.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: value1/3, y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: (value1/3)+(value1/3), y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 51{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: value2/3)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2/3-6)
            self.view5_2.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: (value2/3)+(value2/3))
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: (value2/3)+(value2/3)-6)
            self.view5_3.frame = CGRect(x: 0, y: value2/3, width: value1/3, height: (value2/3)+(value2/3))
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: (value2/3)+(value2/3)-6)
            self.view5_4.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: value1/3, y: (value2/3)+(value2/3), width: (value1/3)+(value1/3), height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 52{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value1, height: (value2/3)+(value2/3))
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value1-6, height: (value2/3)+(value2/3)-6)
            self.view5_2.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1/4, height: value2/3)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2/3-6)
            self.view5_3.frame = CGRect(x: value1/4, y: (value2/3)+(value2/3), width: value1/4, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: (value1/4)+(value1/4), y: (value2/3)+(value2/3), width: value1/4, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: (value1/4)+(value1/4)+(value1/4), y: (value2/3)+(value2/3), width: value1/4, height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value1/4-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 53{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value3, height: value2/3)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view5_2.frame = CGRect(x: value3, y: 0, width: value3, height: value2/3)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view5_3.frame = CGRect(x: 0, y: value2/3, width: value1, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: value3, y: (value2/3)+(value2/3), width: value3, height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value3-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 54{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value4)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view5_2.frame = CGRect(x: 0, y: value4, width: value1/3, height: value4)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view5_3.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value2)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view5_4.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value4)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            self.view5_5.frame = CGRect(x: (value1/3)+(value1/3), y: value4, width: value1/3, height: value4)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value4-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 55{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            self.view5_2.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value2/3)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_3.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: value1/3, y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 56{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: value2/3)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2/3-6)
            self.view5_2.frame =  CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2/3)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_3.frame = CGRect(x: 0, y: value2/3, width: value1, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: 0, y: (value2/3)+(value2/3), width: value1/3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: value1/3, y: (value2/3)+(value2/3), width: (value1/3)+(value1/3), height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }else if index == 57{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: (value1/3)+(value1/3), height: value2)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: value2-6)
            self.view5_2.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2/4)
            self.img5_2.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/4-6)
            self.view5_3.frame = CGRect(x: (value1/3)+(value1/3), y: value2/4, width: value1/3, height: value2/4)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/4-6)
            self.view5_4.frame = CGRect(x: (value1/3)+(value1/3), y: (value2/4)+(value2/4), width: value1/3, height: value2/4)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/4-6)
            self.view5_5.frame =  CGRect(x: (value1/3)+(value1/3), y: (value2/4)+(value2/4)+(value2/4), width: value1/3, height: value2/4)
            self.img5_5.frame =  CGRect(x: 3, y: 3, width: value1/3-6, height: value2/4-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        } else if index == 58{
            self.view5Photo.isHidden = false
            self.view5_1.frame = CGRect(x: 0, y: 0, width: value1/3, height: value2/3)
            self.img5_1.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_2.frame = CGRect(x: 0, y: value2/3, width: (value1/3)+(value1/3), height: (value1/3)+(value1/3))
            self.img5_2.frame = CGRect(x: 3, y: 3, width: (value1/3)+(value1/3)-6, height: (value1/3)+(value1/3)-6)
            self.view5_3.frame = CGRect(x: value1/3, y: 0, width: value1/3, height: value2/3)
            self.img5_3.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_4.frame = CGRect(x: (value1/3)+(value1/3), y: 0, width: value1/3, height: value2/3)
            self.img5_4.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            self.view5_5.frame = CGRect(x: (value1/3)+(value1/3), y: value2/3, width: value1/3, height: value2/3)
            self.img5_5.frame = CGRect(x: 3, y: 3, width: value1/3-6, height: value2/3-6)
            btn5_1.frame = self.img5_1.frame
            btn5_2.frame = self.img5_2.frame
            btn5_3.frame = self.img5_3.frame
            btn5_4.frame = self.img5_4.frame
            btn5_5.frame = self.img5_5.frame
        }
//        else if index == 58 {
//            self.view5Photo.isHidden = false
//            self.viewWhite.isHidden = false
//            self.view5_1.frame = CGRect(x: 0, y: 0, width: value3, height: value4)
//            self.img5_1.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
//            self.view5_2.frame = CGRect(x: value3, y: 0, width: value3, height: value4)
//            self.img5_2.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
//            self.view5_3.frame = CGRect(x: 0, y: value4, width: value3, height: value4)
//            self.img5_3.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
//            self.view5_4.frame = CGRect(x: value3, y: value4, width: value3, height: value4)
//            self.img5_4.frame = CGRect(x: 3, y: 3, width: value3-6, height: value4-6)
////            self.viewWhite.frame = CGRect(x: value1/3, y: value2/3, width: value1/3, height: value2/3)
////            self.viewWhite.backgroundColor = UIColor.white
//            btn5_1.frame = self.img5_1.frame
//            btn5_2.frame = self.img5_2.frame
//            btn5_3.frame = self.img5_3.frame
//            btn5_4.frame = self.img5_4.frame
//        }
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
    
    //MARK:- Tableview Delegate
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
    func displayMyAlertMessage(userMessage:String){
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            if isImageEmpty == true{
                arrOfTotalImg[imgIndex] = pickedImage
                imgFilter = pickedImage
            }else{
                let index = arrOfTotalImg.count
                arrOfTotalImg.insert(pickedImage, at: index)
                imgFilter = pickedImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
        for item in viewMain.subviews {
            if item is UIView{
                for i in item.subviews{
                    if i is UIView{
                        for j in i.subviews{
                            if j is UIButton{
                                if isSelectGallery == true{
                                    let btn : UIButton = j as! UIButton
                                    btn.isUserInteractionEnabled = true
                                }
                            }
                        }
                    }
                }
            }
        }
        viewReplaceImg.isHidden = true
        viewMainItems.isHidden = false
        setView(view: viewMainItems)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImageEDITViewcontroller: ImageScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension ImageEDITViewcontroller {
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
