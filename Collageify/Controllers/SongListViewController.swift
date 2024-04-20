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

class SongListViewController: UIViewController {

    @IBOutlet weak var tblSongs: UITableView!
    
    var recommendations: RecommendationsModel?
    let group = DispatchGroup()
    var player: AVPlayer?
    var selectedPlayIndex = -1
    var selectedURL : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        group.enter()
        tblSongs.delegate = self
        tblSongs.dataSource = self
        
        DispatchQueue.main.async {
            SVProgressHUD.show()
            SpotifyRepository.shared.getRecommedationGenre { result in
                switch result {
                case .success(let model):
                    let genres = model.genres
                    var seeds = Set<String>()
                    while seeds.count < 5 {
                        if let random = genres.randomElement() {
                            seeds.insert(random)
                        }
                    }
                    SpotifyRepository.shared.getRecommendations(genres: seeds) { recommendedResult in
                        defer {
                            self.group.leave()
                        }
                        switch recommendedResult {
                        case .success(let model):
                            self.recommendations = model
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.group.notify(queue: .main) {
                SVProgressHUD.dismiss()
                self.tblSongs.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations?.tracks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableCell", for: indexPath) as? SongsTableCell else { return UITableViewCell() }
        
        cell.imgWave.isHidden = selectedPlayIndex != indexPath.row
        cell.imgWave.loadGif(name: "wave")
        
        cell.btnAddSong.tag = indexPath.row
        cell.btnAddSong.addTarget(self, action: #selector(actionAddSong(_ :)), for: .touchUpInside)
        
        
        let result = recommendations?.tracks[indexPath.row]
        cell.lblSongName.text = result?.name
        cell.lblArtist.text = result?.artists.first?.name ?? ""
        cell.imgSongs.sd_setImage(with: URL(string: result?.album?.images.first?.url ?? ""), placeholderImage: UIImage(named: "playlist_artwork_placeholder"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        selectedPlayIndex = indexPath.row
        
        guard let result = recommendations?.tracks[indexPath.row] else { return }
        playTrack(track: result)
    }
    
    @objc func actionAddSong(_ sender: UIButton) {
        let result = recommendations?.tracks[sender.tag]
        audioUrl = URL(string: result?.previewUrl ?? "")
        self.dismiss(animated: true) {
            self.selectedURL?()
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
