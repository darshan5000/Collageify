//
//  SongSearchViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 16/04/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import SDWebImage
import GoogleMobileAds // Import Google Mobile Ads
import MusicKit
import StoreKit

class SongsTableCell: UITableViewCell {
    @IBOutlet weak var imgSongs: UIImageView!
    @IBOutlet weak var imgWave: UIImageView!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var btnAddSong: UIButton!
    @IBOutlet weak var lblNumber: UILabel!
}

class SongSearchViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var collArtistList: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSongs: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var selectedURL : (() -> Void)?
    var player: AVPlayer?
    var selectedPlayIndex = -1
    private let appleMusicAPI = AppleMusicAPI.shared
    var songsList = [Song]()
    var artistList = [SearchArtist]()
//    var songsList : MusicItemCollection<Album> = []
//    var artistList : MusicItemCollection<Album> = []
    var controller = SKCloudServiceController()
    var isPuchased = false
    
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
        tblSongs.delegate = self
        tblSongs.dataSource = self
        collArtistList.delegate = self
        collArtistList.dataSource = self
        let nib = UINib(nibName: "ArtistCollectionViewCell", bundle: nil)
        collArtistList.register(nib, forCellWithReuseIdentifier: "ArtistCollectionViewCell")
        collArtistList.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.allowAccess()
        }
    }
    
    @objc func allowAccess() {
        if SKCloudServiceController.authorizationStatus() == .notDetermined {
            SKCloudServiceController.requestAuthorization { status in
                switch status {
                case .restricted:
                    print("restricted")
                    self.dismiss(animated: true)
                case .authorized:
                    self.checkPurchsedOrNot()
                case .denied:
                    print("denied")
                    self.dismiss(animated: true)
                case .notDetermined:
                    print("notDetermined")
                    self.dismiss(animated: true)
                @unknown default:
                    break
                }
            }
        } else if SKCloudServiceController.authorizationStatus() == .restricted {
            //Sending user to apps settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        } else if SKCloudServiceController.authorizationStatus() == .denied {
            //Sending user to apps settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    func checkPurchsedOrNot() {
        
        DispatchQueue.global(qos: .default).async { [self] in
            getPlaylists { [self] result  in
                switch result {
                case .SUCCESS:
                    print("SUCCESS")
                    isPuchased = true
                case .FAILED:
                    print("FAILED")
                case .USERHASNOSUBSCRIPTION:
                    showAppleMusicSignup()
                case .denied:
                    allowAccess()
                case .restricted:
                    allowAccess()
                case .notDetermined:
                    allowAccess()
                }
            }
        }
    }
    
    func getPlaylists(onCompletion: @escaping (GetPlaylistsResults) -> Void) {
        appleMusicAPI.checkIfAppleMusicIsAvailable { [self] result in
            switch result {
            case .authorized:
                //AUTHORIZED. Check if user has an apple music subscription
                appleMusicAPI.checkIfUserHasAppleMusicSubscription { result in
                    switch result {
                    case .SUCCESS:
                        onCompletion(.SUCCESS)
                    case .FAILED:
                        onCompletion(.USERHASNOSUBSCRIPTION)
                    case .none:
                        onCompletion(.USERHASNOSUBSCRIPTION)
                    }
                }
            case .restricted:
                onCompletion(.restricted)
            case .denied:
                onCompletion(.denied)
            case .notDetermined:
                onCompletion(.notDetermined)
            case .none:
                onCompletion(.notDetermined)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionSearch(_ sender: UIButton) {
        player?.pause()
        selectedPlayIndex = -1
        
        let keywords = txtSearch.text
        let finalkeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        if finalkeywords != "" {
            view.endEditing(true)
            SVProgressHUD.show()

            appleMusicAPI.appleMusicSearch(searchString: finalkeywords ?? "") { result, playlists in
                SVProgressHUD.dismiss()
                print(result)
                self.songsList = playlists ?? []
                DispatchQueue.main.async {
                    self.tblSongs.reloadData()
                }
            }
            
            appleMusicAPI.appleArtistSearch(searchString: finalkeywords ?? "") { results, songs in
                self.artistList = songs ?? []
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.collArtistList.isHidden = self.songsList.count < 0
                    self.collArtistList.reloadData()
                }
            }
        }
    }
}

extension SongSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCollectionViewCell", for: indexPath) as? ArtistCollectionViewCell else { return UICollectionViewCell() }
        
        let result = artistList[indexPath.row]
        cell.lblArtist.text = result.artistNamee
        let imageURL = result.artworkURL.replacingOccurrences(of: "{w}x{h}", with: "200x200")
        cell.imgArtist.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "avatar1"))
//        cell.imgArtist.sd_setImage(with: result.artwork?.url(width: 200, height: 200), placeholderImage: UIImage(named: "avatar1"))
        cell.imgArtist.layer.cornerRadius = cell.imgArtist.bounds.height / 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height - 20, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlbumsViewController") as! AlbumsViewController
//        vc.album = artistList[indexPath.row]
        vc.selectedID = self.artistList[indexPath.item].id
        vc.selectedURL = {
            self.dismiss(animated: false) {
                self.selectedURL?()
            }
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

//MARK: -Apple music requests
extension SongSearchViewController: SKCloudServiceSetupViewControllerDelegate {
    @objc func showAppleMusicSignup() {
        let vc = SKCloudServiceSetupViewController()
        vc.delegate = self
        let options: [SKCloudServiceSetupOptionsKey: Any] = [.action: SKCloudServiceSetupAction.subscribe, .messageIdentifier: SKCloudServiceSetupMessageIdentifier.playMusic]
        vc.load(options: options) { success, error in
            if success {
                self.present(vc, animated: true)
            }
        }
    }
}

extension SongSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsList.count //trackArray.count//searchSonges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableCell", for: indexPath) as? SongsTableCell else { return UITableViewCell() }
        
        cell.imgWave.isHidden = selectedPlayIndex != indexPath.row
        cell.imgWave.loadGif(name: "wave")
        
        cell.btnAddSong.tag = indexPath.row
        cell.btnAddSong.addTarget(self, action: #selector(actionAddSong(_ :)), for: .touchUpInside)
        
        let result = songsList[indexPath.row]
        cell.lblSongName.text = result.name
        cell.lblArtist.text = result.artistNamee
        let imageURL = result.artworkURL.replacingOccurrences(of: "{w}x{h}", with: "200x200")
        cell.imgSongs.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
        
//        cell.lblSongName.text = result.title
//        cell.lblArtist.text = result.artistName
//        cell.imgSongs.sd_setImage(with: result.artwork?.url(width: 200, height: 200), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
        cell.imgSongs.layer.cornerRadius = 5
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        selectedPlayIndex = indexPath.row
        let result = songsList[indexPath.row]
        playTrack(track: result.songURL)
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "SongListViewController") as! SongListViewController
//        vc.album = songsList[indexPath.row]
//        vc.selectedURL = {
//            self.dismiss(animated: false) {
//                self.selectedURL?()
//            }
//        }
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true)
    }
    
    @objc func actionAddSong(_ sender: UIButton) {
        let result = songsList[sender.tag]
        audioUrl = URL(string: result.songURL)
        self.dismiss(animated: true) {
            self.selectedURL?()
        }
        
//        let result = searchSonges[sender.tag]
//        switch result {
//        case .artist(_):
//            break
//        case .album(_):
//            break
//        case .track(let model):
//            audioUrl = URL(string: model.previewUrl ?? "")
//            self.dismiss(animated: true) {
//                self.selectedURL?()
//            }
//        case .playlist(_):
//            break
//        }
    }
    
    func playTrack(track: String) {
        guard let url = URL(string: track) else {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            let playerItem: AVPlayerItem = AVPlayerItem(url: url)
            
            player?.pause()
            player = AVPlayer(playerItem: playerItem)
            
            player?.play()
            player?.volume = 1
        
            tblSongs.reloadData()
        } catch {
        }
    }
    
//    func playTrack(track: AudioTrack) {
//        guard let url = URL(string: track.previewUrl ?? "") else {
//            return
//        }
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//            try AVAudioSession.sharedInstance().setMode(.default)
//            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//
//            let playerItem: AVPlayerItem = AVPlayerItem(url: url)
//
//            player?.pause()
//            player = AVPlayer(playerItem: playerItem)
//
//            player?.play()
//            player?.volume = 1
//
//            tblSongs.reloadData()
//        } catch {
//        }
//    }
}
