//
//  EditReelsViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 09/04/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds // Import Google Mobile Ads


class EditReelsViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var collPreview: UICollectionView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var arrayAsset : [VideoData] = []
    var actionDone : ((_ data: [VideoData]) -> Void)?
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if IS_ADS_SHOW == true {
            if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
                bannerView.adUnitID = adUnitID1
            }
            
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
        collPreview.register(UINib(nibName: "EditPreviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EditPreviewCollectionViewCell")
        collPreview.delegate = self
        collPreview.dataSource = self
    }
    
    @IBAction func actionEdit(_ sender: UIButton) {
        if arrayAsset[selectedIndex].isVideo {
            let obj : VideoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "VideoEditViewController") as! VideoEditViewController
            obj.videoAsset = arrayAsset[selectedIndex]
            obj.actionAssetDone = { assett in
                self.arrayAsset[self.selectedIndex].asset = assett
                self.collPreview.reloadData()
            }
            obj.modalPresentationStyle = .fullScreen
            self.present(obj, animated: true, completion: nil)
        } else {
            let cropper = CropperViewController(originalImage: arrayAsset[selectedIndex].image ?? UIImage())
            cropper.delegate = self
            self.present(cropper, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionNext(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        actionDone?(arrayAsset)
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
}

extension EditReelsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditPreviewCollectionViewCell", for: indexPath) as? EditPreviewCollectionViewCell else { return UICollectionViewCell() }
        
        let dict = arrayAsset[indexPath.row]
        if dict.isVideo {
            cell.imgPlay.isHidden = false
            generateThumbnail(from: dict.asset ?? AVAsset()) { thumbnail in
                DispatchQueue.main.async {
                    cell.imgPreview.image = thumbnail
                }
            }
        } else {
            cell.imgPlay.isHidden = true
            cell.imgPreview.image = dict.image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func generateThumbnail(from asset: AVAsset, completion: @escaping (UIImage?) -> Void) {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            completion(thumbnail)
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collPreview.contentOffset
        visibleRect.size = collPreview.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collPreview.indexPathForItem(at: visiblePoint) else { return }
        selectedIndex = indexPath.item
//        if arrayAsset[selectedIndex].isVideo {
//            btnEdit.isHidden = true
//        } else {
//            btnEdit.isHidden = false
//        }
    }
}

extension EditReelsViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)
        if let state = state, let image = cropper.originalImage.cropped(withCropperState: state) {
            arrayAsset[selectedIndex].image = image
            collPreview.reloadData()
        }
    }
}
