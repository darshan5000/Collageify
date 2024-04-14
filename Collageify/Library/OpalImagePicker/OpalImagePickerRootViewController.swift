//
//  OpalImagePickerRootViewController.swift
//  OpalImagePicker
//
//  Created by Kristos Katsanevas on 1/16/17.
//  Copyright © 2017 Opal Orange LLC. All rights reserved.
//

import UIKit
import Photos

/// Image Picker Root View Controller contains the logic for selecting images. The images are displayed in a `UICollectionView`, and multiple images can be selected.
open class OpalImagePickerRootViewController: UIViewController {
    
    /// Delegate for Image Picker. Notifies when images are selected (done is tapped) or when the Image Picker is cancelled.
    open weak var delegate: OpalImagePickerControllerDelegate?
    
    /// Configuration to change Localized Strings
    open var configuration: OpalImagePickerConfiguration? {
        didSet {
            configuration?.updateStrings = configurationChanged
            if let configuration = self.configuration {
                configurationChanged(configuration)
            }
        }
    }
    
    /// `UICollectionView` for displaying photo library images
    open weak var collectionView: UICollectionView?
    
    open weak var collectionViewBottom: UICollectionView?
    
    /// `UICollectionView` for displaying external images
    open weak var externalCollectionView: UICollectionView?
    
    /// `UIToolbar` to switch between Photo Library and External Images.
    open lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    /// `UISegmentedControl` to switch between Photo Library and External Images.
    open lazy var tabSegmentedControl: UISegmentedControl = {
        let tabSegmentedControl = UISegmentedControl(items: [NSLocalizedString("Library", comment: "Library"), NSLocalizedString("External", comment: "External")])
        tabSegmentedControl.addTarget(self, action: #selector(segmentTapped(_:)), for: .valueChanged)
        tabSegmentedControl.selectedSegmentIndex = 0
        return tabSegmentedControl
    }()
    
    /// Custom Tint Color for overlay of selected images.
    open var selectionTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom Tint Color for selection image (checkmark).
    open var selectionImageTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom selection image (checkmark).
    open var selectionImage: UIImage? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Allowed Media Types that can be fetched. See `PHAssetMediaType`
    open var allowedMediaTypes: Set<PHAssetMediaType>? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Allowed MediaSubtype that can be fetched. Can be applied as `OptionSet`. See `PHAssetMediaSubtype`
    open var allowedMediaSubtypes: PHAssetMediaSubtype? {
        didSet {
            updateFetchOptionPredicate()
        }
    }
    
    /// Maximum photo selections allowed in picker (zero or fewer means unlimited).
    open var maximumSelectionsAllowed: Int = -1
    
    /// Page size for paging through the Photo Assets in the Photo Library. Defaults to 100. Must override to change this value. Only works in iOS 9.0+
    public let pageSize = 100
    
    var photoAssets: PHFetchResult<PHAsset> = PHFetchResult()
    weak var doneButton: UIBarButtonItem?
    weak var cancelButton: UIBarButtonItem?
    
    internal var collectionViewLayout: OpalImagePickerCollectionViewLayout? {
        return collectionView?.collectionViewLayout as? OpalImagePickerCollectionViewLayout
    }
    
    internal lazy var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    @available(iOS 9.0, *)
    internal var fetchLimit: Int {
        get {
            return fetchOptions.fetchLimit
        }
        set {
            fetchOptions.fetchLimit = newValue
        }
    }
    
    internal var shouldShowTabs: Bool {
        guard let imagePicker = navigationController as? OpalImagePickerController else { return false }
        return delegate?.imagePickerNumberOfExternalItems?(imagePicker) != nil
    }
    
    private var isCompleted = false
    private var photosCompleted = 0
    private var savedImages: [UIImage] = []
    private var showExternalImages = false
    private var selectedIndexPaths: [IndexPath] = [] {
        didSet {
            self.lblCount.text = " \(selectedIndexPaths.count) "
            self.btnContinue.isHidden = selectedIndexPaths.count <= 0
            if selectedIndexPaths.count > 0 {
                self.collHeightConst?.constant = 80
            } else {
                self.collHeightConst?.constant = 0
            }
        }
    }
    private var externalSelectedIndexPaths: [IndexPath] = []
    
    private lazy var cache: NSCache<NSIndexPath, NSData> = {
        let cache = NSCache<NSIndexPath, NSData>()
        cache.totalCostLimit = 128000000 //128 MB
        cache.countLimit = 100 // 100 images
        return cache
    }()
    
    private weak var rightExternalCollectionViewConstraint: NSLayoutConstraint?
    
    /// Initializer
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Initializer (Do not use this View Controller in Interface Builder)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot init \(String(describing: OpalImagePickerRootViewController.self)) from Interface Builder")
    }
    
    var selectedDict = [String : Int]()
    var selectedBottomImages = [[String: Any]]()
    var mainTopView: UIView?
    
    var collectionBGView = UIView() {
        didSet {
            self.collectionBGView.clipsToBounds = true
            self.collectionBGView.layer.cornerRadius = 15
            self.collectionBGView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            self.collectionBGView.backgroundColor = UIColor.black
        }
    }
    
    var lblSelectedCount = UILabel() {
        didSet {
            self.lblSelectedCount.text = "Selected"
            self.lblSelectedCount.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            self.lblSelectedCount.textColor = .lightGray
            self.lblSelectedCount.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var lblCount = UILabel() {
        didSet {
            self.lblCount.clipsToBounds = true
            self.lblCount.textColor = .black
            self.lblCount.translatesAutoresizingMaskIntoConstraints = false
            self.lblCount.layer.cornerRadius = 8
            self.lblCount.backgroundColor = .yellow
            self.lblCount.font = UIFont(name: "AvenirNext-Bold", size: 14)
        }
    }
    
    var btnContinue = UIButton() {
        didSet {
            btnContinue.clipsToBounds = true
            btnContinue.backgroundColor = .systemYellow
            self.btnContinue.translatesAutoresizingMaskIntoConstraints = false
            btnContinue.setTitleColor(.black, for: .normal)
            btnContinue.setTitle("      Continue      ", for: .normal)
            btnContinue.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 11)
            btnContinue.layer.cornerRadius = 18
        }
    }
    
    var curruntSelectedBottomIndex = -1
    var collHeightConst: NSLayoutConstraint?
    
    private func setup() {
        guard let view = view else { return }
        fetchPhotos()
        
        let parts = selectedDict["parts"] ?? 0
        for _ in 0..<parts {
            let dict = ["image" : UIImage(), "index": IndexPath()] as [String : Any]
            selectedBottomImages.append(dict)
        }
        
        view.backgroundColor = UIColor(red: 18.0/255.0, green: 15/255.0, blue: 19/255.0, alpha: 1.0)
        
        let window = UIApplication.shared.windows.first
        let padding = window?.safeAreaInsets.bottom ?? 0
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        // Top DissmissButton
        let crossButton = UIButton()
        crossButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.addSubview(crossButton)
        crossButton.setImage(UIImage(named: "close"), for: .normal)
        crossButton.tintColor = .white
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        crossButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 15).isActive = true
        crossButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        crossButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        crossButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        crossButton.addTarget(self, action: #selector(cancelTapped(_ :)), for: .touchUpInside)
        
        // collectionView Main setup
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: OpalImagePickerCollectionViewLayout())
        setup(collectionView: collectionView)
        view.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        
        // collectionView Main Constraint
        var constraints: [NSLayoutConstraint] = []
        if shouldShowTabs {
            setupTabs()
            let externalCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: OpalImagePickerCollectionViewLayout())
            setup(collectionView: externalCollectionView)
            view.addSubview(externalCollectionView)
            self.externalCollectionView = externalCollectionView
            
            constraints += [externalCollectionView.constraintEqualTo(with: collectionView, attribute: .top)]
            constraints += [externalCollectionView.constraintEqualTo(with: collectionView, attribute: .bottom)]
            constraints += [externalCollectionView.constraintEqualTo(with: collectionView, receiverAttribute: .left, otherAttribute: .right)]
            constraints += [collectionView.constraintEqualTo(with: view, attribute: .width)]
            constraints += [externalCollectionView.constraintEqualTo(with: view, attribute: .width)]
            constraints += [toolbar.constraintEqualTo(with: collectionView, receiverAttribute: .bottom, otherAttribute: .top)]
        } else {
            constraints += [view.constraintEqualTo(with: collectionView, attribute: .top, constant: -(topPadding + crossButton.bounds.height + 60))]
            constraints += [view.constraintEqualTo(with: collectionView, attribute: .right)]
        }
        
        //Lower priority to override left constraint for animations
        let leftCollectionViewConstraint = view.constraintEqualTo(with: collectionView, attribute: .left)
        leftCollectionViewConstraint.priority = UILayoutPriority(rawValue: 999)
        constraints += [leftCollectionViewConstraint]
        
        constraints += [view.constraintEqualTo(with: collectionView, attribute: .bottom, constant: 0)]
        NSLayoutConstraint.activate(constraints)
        
        // Bottom Main View
        self.collectionBGView = UIView()
        view.addSubview(self.collectionBGView)
        self.collectionBGView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionBGView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionBGView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.collectionBGView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        // selected Label
        lblSelectedCount = UILabel()
        collectionBGView.addSubview(self.lblSelectedCount)
        self.lblSelectedCount.translatesAutoresizingMaskIntoConstraints = false
        self.lblSelectedCount.topAnchor.constraint(equalTo: self.collectionBGView.topAnchor, constant: 30).isActive = true
        self.lblSelectedCount.leadingAnchor.constraint(equalTo: self.collectionBGView.leadingAnchor, constant: 20).isActive = true
        self.lblSelectedCount.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // Count Label
        lblCount = UILabel()
        collectionBGView.addSubview(self.lblCount)
        self.lblCount.translatesAutoresizingMaskIntoConstraints = false
        lblCount.centerYAnchor.constraint(equalTo: self.lblSelectedCount.centerYAnchor).isActive = true
        self.lblCount.leadingAnchor.constraint(equalTo: self.lblSelectedCount.trailingAnchor, constant: 8).isActive = true
        self.lblCount.heightAnchor.constraint(equalToConstant: 23).isActive = true
        
        // Button Continue
        btnContinue = UIButton()
        collectionBGView.addSubview(self.btnContinue)
        self.btnContinue.translatesAutoresizingMaskIntoConstraints = false
        btnContinue.centerYAnchor.constraint(equalTo: self.lblSelectedCount.centerYAnchor).isActive = true
        self.btnContinue.trailingAnchor.constraint(equalTo: self.collectionBGView.trailingAnchor, constant: -15).isActive = true
        self.btnContinue.heightAnchor.constraint(equalToConstant: 38).isActive = true
        self.btnContinue.addTarget(self, action: #selector(actionContinueButton(_ :)), for: .touchUpInside)
        
        // collectionView Bottom setup
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionViewbottom = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionViewbottom.tag = 1
        setup(collectionView: collectionViewbottom)
        self.collectionBGView.addSubview(collectionViewbottom)
        collectionViewbottom.showsHorizontalScrollIndicator = false
        self.collectionViewBottom = collectionViewbottom
        self.collectionViewBottom?.backgroundColor = UIColor.clear
        self.collectionViewBottom?.translatesAutoresizingMaskIntoConstraints = false
        self.collectionViewBottom?.topAnchor.constraint(equalTo: self.btnContinue.bottomAnchor, constant: 20).isActive = true
        self.collectionViewBottom?.leadingAnchor.constraint(equalTo: self.collectionBGView.leadingAnchor, constant: 0).isActive = true
        self.collectionViewBottom?.trailingAnchor.constraint(equalTo: self.collectionBGView.trailingAnchor, constant: 0).isActive = true
        self.collectionViewBottom?.bottomAnchor.constraint(equalTo: self.collectionBGView.bottomAnchor, constant: -padding).isActive = true
        collHeightConst = self.collectionViewBottom?.heightAnchor.constraint(equalToConstant: 0)
        collHeightConst?.isActive = true
        self.collectionViewBottom?.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        DispatchQueue.main.async {
            self.mainTopView = UIView()
            view.addSubview(self.mainTopView ?? UIView())
            self.mainTopView?.translatesAutoresizingMaskIntoConstraints = false
            self.mainTopView?.leadingAnchor.constraint(equalTo: self.collectionView!.leadingAnchor).isActive = true
            self.mainTopView?.trailingAnchor.constraint(equalTo: self.collectionView!.trailingAnchor).isActive = true
            self.mainTopView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.mainTopView?.bottomAnchor.constraint(equalTo: self.collectionView!.bottomAnchor).isActive = true

            self.mainTopView?.isHidden = true
        }
        
        view.layoutIfNeeded()
        selectedIndexPaths = []
    }
    
    private func setup(collectionView: UICollectionView) {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        if collectionView.tag == 0 {
            collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.reuseId)
        } else {
            collectionView.register(BottomImageCollectionViewCell.self, forCellWithReuseIdentifier: BottomImageCollectionViewCell.reuseId)
        }
    }
    
    private func setupTabs() {
        guard let view = view else { return }
        
        edgesForExtendedLayout = UIRectEdge()
        navigationController?.navigationBar.isTranslucent = false
        toolbar.isTranslucent = false
        
        view.addSubview(toolbar)
        let flexItem1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButtonItem = UIBarButtonItem(customView: tabSegmentedControl)
        toolbar.setItems([flexItem1, barButtonItem, flexItem2], animated: false)
        
        if let imagePicker = navigationController as? OpalImagePickerController,
           let title = delegate?.imagePickerTitleForExternalItems?(imagePicker) {
            tabSegmentedControl.setTitle(title, forSegmentAt: 1)
        }
        
        NSLayoutConstraint.activate([
            toolbar.constraintEqualTo(with: topLayoutGuide, receiverAttribute: .top, otherAttribute: .bottom),
            toolbar.constraintEqualTo(with: view, attribute: .left),
            toolbar.constraintEqualTo(with: view, attribute: .right)
        ])
    }
    
    private func fetchPhotos() {
        requestPhotoAccessIfNeeded(PHPhotoLibrary.authorizationStatus())
        
        if #available(iOS 9.0, *) {
            fetchOptions.fetchLimit = pageSize
        }
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        collectionView?.reloadData()
    }
    
    private func updateFetchOptionPredicate() {
        var predicates: [NSPredicate] = []
        if let allowedMediaTypes = self.allowedMediaTypes {
            let mediaTypesPredicates = allowedMediaTypes.map { NSPredicate(format: "mediaType = %d", $0.rawValue) }
            let allowedMediaTypesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: mediaTypesPredicates)
            predicates += [allowedMediaTypesPredicate]
        }
        
        if let allowedMediaSubtypes = self.allowedMediaSubtypes {
            let mediaSubtypes = NSPredicate(format: "(mediaSubtype & %d) == 0", allowedMediaSubtypes.rawValue)
            predicates += [mediaSubtypes]
        }
        
        if predicates.count > 0 {
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchOptions.predicate = predicate
        } else {
            fetchOptions.predicate = nil
        }
        fetchPhotos()
    }
    
    /// Load View
    open override func loadView() {
        view = UIView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setup()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isCompleted = false
    }
    
    @objc func cancelTapped(_ sender: UIButton) {
        cancelTab()
    }
    
    func cancelTab() {
        dismiss(animated: true) { [weak self] in
            guard let imagePicker = self?.navigationController as? OpalImagePickerController else { return }
            self?.delegate?.imagePickerDidCancel?(imagePicker)
        }
    }
    
    @objc func doneTapped() {
        guard let imagePicker = navigationController as? OpalImagePickerController,
              !isCompleted else { return }
        
        let indexPathsForSelectedItems = selectedIndexPaths
        let externalIndexPaths = externalSelectedIndexPaths
        guard indexPathsForSelectedItems.count + externalIndexPaths.count > 0 else {
            cancelTab()
            return
        }
        
        var photoAssets: [PHAsset] = []
        for indexPath in indexPathsForSelectedItems {
            guard indexPath.item < self.photoAssets.count else { continue }
            photoAssets += [self.photoAssets.object(at: indexPath.item)]
        }
        delegate?.imagePicker?(imagePicker, didFinishPickingAssets: photoAssets, allImages: selectedBottomImages)
        
        var selectedURLs: [URL] = []
        for indexPath in externalIndexPaths {
            guard let url = delegate?.imagePicker?(imagePicker, imageURLforExternalItemAtIndex: indexPath.item) else { continue }
            selectedURLs += [url]
        }
        delegate?.imagePicker?(imagePicker, didFinishPickingExternalURLs: selectedURLs)
    }
    
    private func set(image: UIImage?, indexPath: IndexPath, isExternal: Bool) {
        update(isSelected: image != nil, isExternal: isExternal, for: indexPath)
    }
    
    private func update(isSelected: Bool, isExternal: Bool, for indexPath: IndexPath) {
        if isSelected && isExternal {
            externalSelectedIndexPaths += [indexPath]
        } else if !isSelected && isExternal {
            externalSelectedIndexPaths = externalSelectedIndexPaths.filter { $0 != indexPath }
        } else if isSelected && !isExternal {
            selectedIndexPaths += [indexPath]
        } else {
            selectedIndexPaths = selectedIndexPaths.filter { $0 != indexPath }
        }
    }
    
    @available(iOS 9.0, *)
    private func fetchNextPageIfNeeded(indexPath: IndexPath) {
        guard indexPath.item == fetchLimit-1 else { return }
        
        let oldFetchLimit = fetchLimit
        fetchLimit += pageSize
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        var indexPaths: [IndexPath] = []
        for item in oldFetchLimit..<photoAssets.count {
            indexPaths += [IndexPath(item: item, section: 0)]
        }
        collectionView?.insertItems(at: indexPaths)
    }
    
    private func requestPhotoAccessIfNeeded(_ status: PHAuthorizationStatus) {
        guard status == .notDetermined else { return }
        PHPhotoLibrary.requestAuthorization { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                self?.photoAssets = PHAsset.fetchAssets(with: self?.fetchOptions)
                self?.collectionView?.reloadData()
            }
        }
    }
    
    @objc private func segmentTapped(_ sender: UISegmentedControl) {
        guard let view = view else { return }
        
        showExternalImages = sender.selectedSegmentIndex == 1
        
        //Instantiate right constraint if needed
        if rightExternalCollectionViewConstraint == nil {
            let rightConstraint = externalCollectionView?.constraintEqualTo(with: view, attribute: .right)
            rightExternalCollectionViewConstraint = rightConstraint
        }
        rightExternalCollectionViewConstraint?.isActive = showExternalImages
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            sender.isUserInteractionEnabled = false
            self?.view.layoutIfNeeded()
        }, completion: { _ in
            sender.isUserInteractionEnabled = true
        })
    }
    
    private func configurationChanged(_ configuration: OpalImagePickerConfiguration) {
        if let navigationTitle = configuration.navigationTitle {
            navigationItem.title = navigationTitle
        }
        
        if let librarySegmentTitle = configuration.librarySegmentTitle {
            tabSegmentedControl.setTitle(librarySegmentTitle, forSegmentAt: 0)
        }
    }
    
    @objc func actionRemoveImage(_ sender: UIButton) {
        let indexPath = selectedBottomImages[sender.tag]["index"] as! IndexPath
        set(image: nil, indexPath: indexPath, isExternal: false)
        selectedBottomImages[sender.tag]["image"] = UIImage()
        selectedBottomImages[sender.tag]["index"] = IndexPath()
        self.collectionView?.reloadItems(at: [indexPath])
        self.collectionViewBottom?.reloadData()
    }
    
    @objc func actionContinueButton(_ sender: UIButton) {
        guard let imagePicker = navigationController as? OpalImagePickerController,
              !isCompleted else { return }
        
        let indexPathsForSelectedItems = selectedIndexPaths
        guard indexPathsForSelectedItems.count > 0 else {
            cancelTab()
            return
        }
        
        var photoAssets: [PHAsset] = []
        for indexPath in indexPathsForSelectedItems {
            guard indexPath.item < self.photoAssets.count else { continue }
            photoAssets += [self.photoAssets.object(at: indexPath.item)]
        }
        delegate?.imagePicker?(imagePicker, didFinishPickingAssets: photoAssets, allImages: selectedBottomImages)
    }
}

// MARK: - Collection View Delegate

extension OpalImagePickerRootViewController: UICollectionViewDelegate {
    
    /// Collection View did select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell, let image = cell.imageView.image else { return }
            
            let parts = selectedDict["parts"] ?? 0
            if self.selectedIndexPaths.count >= parts {
                return
            }
            
            if let index = selectedIndexPaths.firstIndex(where: { $0 == indexPath }) {
                return
            } else {
                self.set(image: image, indexPath: indexPath, isExternal: collectionView == self.externalCollectionView)
            }
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.05) {
                self.mainTopView?.isHidden = false
                self.view.bringSubviewToFront(self.mainTopView ?? UIView())
                guard let indexPath = collectionView.indexPath(for: cell), let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
                        assertionFailure("Can't get required attributes")
                        return
                }
                let frameInWindow = collectionView.convert(attributes.frame, to: nil)
                let imageView = UIImageView(frame: frameInWindow)
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                self.mainTopView?.addSubview(imageView)
                
                UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                },completion: { finish in
                    UIView.animate(withDuration: 0.2, delay: 0.10,options: UIView.AnimationOptions.curveLinear,animations: {
                        
                        for i in 0..<self.selectedBottomImages.count {
                            if (self.selectedBottomImages[i]["image"] as? UIImage) == UIImage() {
                                if let cell = self.collectionViewBottom?.cellForItem(at: IndexPath(item: i, section: 0)) as? BottomImageCollectionViewCell {
                                    guard let indexPathh = self.collectionViewBottom?.indexPath(for: cell), let attributes = self.collectionViewBottom?.layoutAttributesForItem(at: indexPathh)
                                    else {
                                        assertionFailure("Can't get required attributes")
                                        return
                                    }
                                    if let frameInWindow = self.collectionViewBottom?.convert(attributes.frame, to: nil) {
                                        imageView.frame = frameInWindow
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.20) {
                                        for view in self.mainTopView?.subviews ?? [] {
                                            view.removeFromSuperview()
                                        }
                                        self.mainTopView?.isHidden = true
                                        let requestOptions = PHImageRequestOptions()
                                        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                                        requestOptions.isSynchronous = true
                                        let dGrrp = DispatchGroup()
                                        let images = self.photoAssets.object(at: indexPath.item)
                                        if (images.mediaType == PHAssetMediaType.image) {
                                            dGrrp.enter()
                                            PHImageManager.default().requestImage(for: images , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                                                self.selectedBottomImages[i]["image"] = pickedImage ?? UIImage()
                                                self.selectedBottomImages[i]["index"] = indexPath
                                                self.collectionView?.reloadItems(at: [indexPath])
                                                self.collectionViewBottom?.reloadData()
                                                dGrrp.leave()
                                            })
                                        }
                                        
                                        // Next Cell
                                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.10) {
                                            if let nextCell = self.collectionViewBottom?.cellForItem(at: IndexPath(item: i + 1, section: 0)) as? BottomImageCollectionViewCell {
                                                let dict = self.selectedDict
                                                nextCell.placeHolderImageView.image = UIImage(named: "\(dict["image"] ?? 0)_\(i + 2)")
                                                self.collectionViewBottom?.scrollToItem(at: IndexPath(item: i + 1, section: 0), at: .centeredHorizontally, animated: true)
                                            }
                                        }
                                    }
                                }
                                break
                            }
                        }
                    },completion: nil)
                })
            }
        } else {
            curruntSelectedBottomIndex = indexPath.row
            collectionViewBottom?.reloadData()
        }
    }
    
    /// Collection View did de-select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        set(image: nil, indexPath: indexPath, isExternal: collectionView == self.externalCollectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == collectionViewBottom {
            return true
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell,
              cell.imageView.image != nil else { return false }
        guard maximumSelectionsAllowed > 0 else { return true }
        
        let collectionViewItems = self.collectionView?.indexPathsForSelectedItems?.count ?? 0
        let externalCollectionViewItems = self.externalCollectionView?.indexPathsForSelectedItems?.count ?? 0
        
        if maximumSelectionsAllowed <= collectionViewItems + externalCollectionViewItems {
            //We exceeded maximum allowed, so alert user. Don't allow selection
            let message = configuration?.maximumSelectionsAllowedMessage ?? NSLocalizedString("You cannot select more than \(maximumSelectionsAllowed) images. Please deselect another image before trying to select again.", comment: "You cannot select more than (x) images. Please deselect another image before trying to select again. (OpalImagePicker)")
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okayString = configuration?.okayString ?? NSLocalizedString("OK", comment: "OK")
            let action = UIAlertAction(title: okayString, style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
}

// MARK: - Collection View Data Source
extension OpalImagePickerRootViewController: UICollectionViewDataSource {
    
    /// Returns Collection View Cell for item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    /// - Returns: Returns the `UICollectionViewCell`
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            return photoAssetCollectionView(collectionView, cellForItemAt: indexPath)
        } else {
            return BottomCollectionView(collectionView, cellForItemAt: indexPath)
            //            return externalCollectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func photoAssetCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if #available(iOS 9.0, *) {
            fetchNextPageIfNeeded(indexPath: indexPath)
        }
        
        guard let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.reuseId, for: indexPath) as? ImagePickerCollectionViewCell else { return UICollectionViewCell() }
        let photoAsset = photoAssets.object(at: indexPath.item)
        if selectedBottomImages.contains(where: {$0["index"] as! IndexPath == indexPath}) {
            cell.setSelected(true, animated: true)
        } else {
            cell.setSelected(false, animated: true)
        }
        cell.indexPath = indexPath
        cell.photoAsset = photoAsset
        cell.size = layoutAttributes.frame.size
        
        if let selectionTintColor = self.selectionTintColor {
            cell.selectionTintColor = selectionTintColor
        }
        if let selectionImageTintColor = self.selectionImageTintColor {
            cell.selectionImageTintColor = selectionImageTintColor
        }
        if let selectionImage = self.selectionImage {
            cell.selectionImage = selectionImage
        }
        
        return cell
    }
    
    private func externalCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imagePicker = navigationController as? OpalImagePickerController,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.reuseId, for: indexPath) as? ImagePickerCollectionViewCell else { return UICollectionViewCell() }
        if let url = delegate?.imagePicker?(imagePicker, imageURLforExternalItemAtIndex: indexPath.item) {
            cell.cache = cache
            cell.url = url
            cell.indexPath = indexPath
        } else {
            assertionFailure("You need to implement `imagePicker(_:imageURLForExternalItemAtIndex:)` in your delegate.")
        }
        
        if let selectionTintColor = self.selectionTintColor {
            cell.selectionTintColor = selectionTintColor
        }
        if let selectionImageTintColor = self.selectionImageTintColor {
            cell.selectionImageTintColor = selectionImageTintColor
        }
        if let selectionImage = self.selectionImage {
            cell.selectionImage = selectionImage
        }
        
        return cell
    }
    
    private func BottomCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomImageCollectionViewCell.reuseId, for: indexPath) as? BottomImageCollectionViewCell else { return UICollectionViewCell() }
        
        let dict = selectedDict
        cell.placeHolderImageView.image = UIImage(named: "\(dict["image"] ?? 0)_g\(indexPath.row + 1)")
        
        let dd = selectedBottomImages[indexPath.row]
        
        cell.imageView.image = dd["image"] as? UIImage
        cell.imageView.layer.cornerRadius = 4
                
        cell.deleteButton.isHidden = (dd["image"] as? UIImage) == UIImage()
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(actionRemoveImage(_ :)), for: .touchUpInside)
        
        cell.layer.borderColor = UIColor.yellow.cgColor
        if curruntSelectedBottomIndex == indexPath.row {
            if (dd["image"] as? UIImage) != UIImage() {
                cell.layer.borderWidth = 0
            } else {
                cell.layer.borderWidth = 0
                cell.placeHolderImageView.image = UIImage(named: "\(dict["image"] ?? 0)_\(indexPath.row + 1)")
            }
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    /// Returns the number of items in a given section
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - section: the given section of the `UICollectionView`
    /// - Returns: Returns an `Int` for the number of rows.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return photoAssets.count
        } else if collectionView == self.collectionViewBottom {
            return selectedDict["parts"] ?? 0
        } else if let imagePicker = navigationController as? OpalImagePickerController,
                  let numberOfItems = delegate?.imagePickerNumberOfExternalItems?(imagePicker) {
            return numberOfItems
        } else {
            assertionFailure("You need to implement `imagePickerNumberOfExternalItems(_:)` in your delegate.")
            return 0
        }
    }
}

extension OpalImagePickerRootViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewBottom {
            return CGSize(width: 70, height: 70)
        }
        return CGSize(width: 80, height: 80)
    }
}
