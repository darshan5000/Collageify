//
//  AlbumsViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 25/04/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import SVProgressHUD

class AlbumsViewController: UIViewController {

    @IBOutlet weak var collAlbumList: UICollectionView!
    
    var selectedID = ""
    private let appleMusicAPI = AppleMusicAPI.shared
    var songsList = [Song]()
    var selectedURL : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collAlbumList.delegate = self
        collAlbumList.dataSource = self
        let nib = UINib(nibName: "AlbumsCollectionViewCell", bundle: nil)
        collAlbumList.register(nib, forCellWithReuseIdentifier: "AlbumsCollectionViewCell")
        collAlbumList.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.show()
            self.appleMusicAPI.appleGetAlbums(playlistId: self.selectedID) { result, songs in
                self.songsList = songs ?? []
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.collAlbumList.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsCollectionViewCell", for: indexPath) as? AlbumsCollectionViewCell else { return UICollectionViewCell() }
        
        let result = songsList[indexPath.row]
        cell.lblAlbumName.text = result.artistNamee
        let imageURL = result.artworkURL.replacingOccurrences(of: "{w}x{h}", with: "500x500")
        cell.imgAlbum.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
        cell.imgAlbum.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 2) - 20, height: (collectionView.bounds.width / 1.6) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SongListViewController") as! SongListViewController
        vc.selectedAlbum = self.songsList[indexPath.item]
        vc.selectedURL = {
            self.dismiss(animated: false) {
                self.selectedURL?()
            }
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
