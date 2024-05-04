//
//  SongListViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 16/04/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import SDWebImage
import MusicKit
import GoogleMobileAds // Import Google Mobile Ads

class SongsArtistCell: UITableViewCell {
    @IBOutlet weak var imgArtist: UIImageView!
    @IBOutlet weak var lblArtistName: UILabel!
}

class SongListViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var tblSongs: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var album : Album?
    
    let group = DispatchGroup()
    var player: AVPlayer?
    var selectedPlayIndex = -1
    var selectedURL : (() -> Void)?
    var selectedAlbum : Song?
    private let appleMusicAPI = AppleMusicAPI.shared
    var songsList = [Song]()
    var tracks: MusicItemCollection<Track>?
    var relatedAlbums: MusicItemCollection<Album>?
    private let applePlayer = ApplicationMusicPlayer.shared
    private var playerState = ApplicationMusicPlayer.shared.state
    
    override func viewDidLoad() {
        super.viewDidLoad()

        group.enter()
        tblSongs.delegate = self
        tblSongs.dataSource = self
        if IS_ADS_SHOW == true {
        if let adUnitID1 = UserDefaults.standard.string(forKey: "BANNER_ID") {
            bannerView.adUnitID = adUnitID1
        }
        
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.show()
            self.appleMusicAPI.appleTracksByAlbum(playlistId: self.selectedAlbum?.id ?? "") { result, songs in
                self.songsList = songs ?? []
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.tblSongs.reloadData()
                }
            }
        }
        
//        DispatchQueue.main.async {
//            SVProgressHUD.show()
//            SpotifyRepository.shared.getRecommedationGenre { result in
//                switch result {
//                case .success(let model):
//                    let genres = model.genres
//                    var seeds = Set<String>()
//                    while seeds.count < 5 {
//                        if let random = genres.randomElement() {
//                            seeds.insert(random)
//                        }
//                    }
//                    SpotifyRepository.shared.getRecommendations(genres: seeds) { recommendedResult in
//                        defer {
//                            self.group.leave()
//                        }
//                        switch recommendedResult {
//                        case .success(let model):
//                            self.recommendations = model
//                        case .failure(let error):
//                            print(error.localizedDescription)
//                        }
//                    }
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//            self.group.notify(queue: .main) {
//                SVProgressHUD.dismiss()
//                self.tblSongs.reloadData()
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
    
    @MainActor
    private func update(tracks: MusicItemCollection<Track>?, relatedAlbums: MusicItemCollection<Album>?) {
        self.tracks = tracks
        self.relatedAlbums = relatedAlbums
    }
    
    @IBAction func actionSearch(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SongSearchViewController") as! SongSearchViewController
        vc.selectedURL = {
            self.dismiss(animated: true) {
                self.selectedURL?()
            }
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension SongListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return songsList.count
        }
//        return songsList.count //recommendations?.tracks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsArtistCell", for: indexPath) as? SongsArtistCell else { return UITableViewCell() }
            
            cell.lblArtistName.text = selectedAlbum?.artistNamee
            let imageURL = selectedAlbum?.artworkURL.replacingOccurrences(of: "{w}x{h}", with: "600x600") ?? ""
            cell.imgArtist.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
            
            //            cell.lblArtistName.text = album?.title
            //            cell.imgArtist.sd_setImage(with: album?.artwork?.url(width: 500, height: 500), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
            cell.imgArtist.layer.cornerRadius = 15
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableCell", for: indexPath) as? SongsTableCell else { return UITableViewCell() }
            
            cell.imgWave.isHidden = selectedPlayIndex != indexPath.row
            cell.imgWave.loadGif(name: "wave")
            
            cell.lblNumber.text = "\(indexPath.row + 1)"
            cell.btnAddSong.tag = indexPath.row
            cell.btnAddSong.addTarget(self, action: #selector(actionAddSong(_ :)), for: .touchUpInside)
            
            let result = songsList[indexPath.row]
            cell.lblSongName.text = result.name
            cell.lblArtist.text = result.artistNamee
            
//            let result = tracks?[indexPath.row]
//            cell.lblSongName.text = result?.title
//            cell.lblArtist.text = result?.artistName
            
    //        let result = recommendations?.tracks[indexPath.row]
    //        cell.lblSongName.text = result?.name
    //        cell.lblArtist.text = result?.artists.first?.name ?? ""
    //        cell.imgSongs.sd_setImage(with: URL(string: result?.album?.images.first?.url ?? ""), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        selectedPlayIndex = indexPath.row
        let result = songsList[indexPath.row]
//        handleTrackSelected(result!, loadedTracks: tracks ?? [])
        playTrack(track: result.songURL)
        
//        guard let result = recommendations?.tracks[indexPath.row] else { return }
//        playTrack(track: result)
    }
    
    private func handleTrackSelected(_ track: Track, loadedTracks: MusicItemCollection<Track>) {
        applePlayer.queue = ApplicationMusicPlayer.Queue(for: loadedTracks, startingAt: track)
        beginPlaying()
    }
    
    func beginPlaying() {
        Task {
            do {
                try await applePlayer.play()
                tblSongs.reloadData()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
    
    @objc func actionAddSong(_ sender: UIButton) {
        let result = songsList[sender.tag]
        audioUrl = URL(string: result.songURL)
//        downloadFileFromURL(url: result?.url)
        
        self.dismiss(animated: false) {
            self.selectedURL?()
        }
    }
    
    func downloadFileFromURL(url: URL?)  {

        if let audioUrl = url {
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//            print(destinationUrl)
            let path = NSTemporaryDirectory().appending("audio.m4a")
            let destinationUrl = URL.init(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path", destinationUrl.path)
            } else {
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder", destinationUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
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
}
