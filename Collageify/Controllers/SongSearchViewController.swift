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


class SongsTableCell: UITableViewCell {
    @IBOutlet weak var imgSongs: UIImageView!
    @IBOutlet weak var imgWave: UIImageView!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var btnAddSong: UIButton!
   
}

class SongSearchViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSongs: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var selectedURL : (() -> Void)?
    private var searchSonges: [SearchResults] = []
    var player: AVPlayer?
    var selectedPlayIndex = -1
    var topSongs: [AudioTrack] = []
    
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
            Task {
                do {
                    let results = try await SpotifyRepository.shared.search(with: finalkeywords ?? "")
                    let tracks = results.filter({
                        switch $0 {
                        case .track: return true
                        default: return false
                        }
                    })
                    await SVProgressHUD.dismiss()
                    searchSonges = tracks
                    tblSongs.reloadData()
                } catch {
                }
            }
        }
    }
}

extension SongSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSonges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableCell", for: indexPath) as? SongsTableCell else { return UITableViewCell() }
        
        cell.imgWave.isHidden = selectedPlayIndex != indexPath.row
        cell.imgWave.loadGif(name: "wave")
        
        cell.btnAddSong.tag = indexPath.row
        cell.btnAddSong.addTarget(self, action: #selector(actionAddSong(_ :)), for: .touchUpInside)
        
        let result = searchSonges[indexPath.row]
        switch result {
        case .artist(_):
            break
        case .album(_):
            break
        case .track(let model):
            cell.lblSongName.text = model.name
            cell.lblArtist.text = model.artists.first?.name ?? ""
            cell.imgSongs.sd_setImage(with: URL(string: model.album?.images.first?.url ?? ""), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
        case .playlist(_):
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        selectedPlayIndex = indexPath.row
        
        let result = searchSonges[indexPath.row]
        switch result {
        case .artist(_):
            break
        case .album(_):
            break
        case .track(let model):
            playTrack(track: model)
        case .playlist(_):
            break
        }
    }
    
    @objc func actionAddSong(_ sender: UIButton) {
        let result = searchSonges[sender.tag]
        switch result {
        case .artist(_):
            break
        case .album(_):
            break
        case .track(let model):
            audioUrl = URL(string: model.previewUrl ?? "")
            self.dismiss(animated: true) {
                self.selectedURL?()
            }
        case .playlist(_):
            break
        }
    }
    
    func playTrack(track: AudioTrack) {
        guard let url = URL(string: track.previewUrl ?? "") else {
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
}
