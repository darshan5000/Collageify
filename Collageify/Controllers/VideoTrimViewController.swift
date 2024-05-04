//
//  VideoTrimViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 02/05/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import AVKit
import SVProgressHUD

extension CMTime {
    var displayString: String {
        let offset = TimeInterval(seconds)
        let numberOfNanosecondsFloat = (offset - TimeInterval(Int(offset))) * 1000.0
        let nanoseconds = Int(numberOfNanosecondsFloat)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return String(format: "%@.%03d", formatter.string(from: offset) ?? "00:00", nanoseconds)
    }
}

extension AVAsset {
    var fullRange: CMTimeRange {
        return CMTimeRange(start: .zero, duration: duration)
    }
    func trimmedComposition(_ range: CMTimeRange) -> AVAsset {
        guard CMTimeRangeEqual(fullRange, range) == false else {return self}

        let composition = AVMutableComposition()
        try? composition.insertTimeRange(range, of: self, at: .zero)

        if let videoTrack = tracks(withMediaType: .video).first {
            composition.tracks.forEach {$0.preferredTransform = videoTrack.preferredTransform}
        }
        return composition
    }
}

class VideoTrimViewController: UIViewController {

    @IBOutlet weak var viewPlay: UIView!
    @IBOutlet weak var viewTrim: UIView!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    let playerController = AVPlayerViewController()
    var trimmer: VideoTrimmer!
    var timingStackView: UIStackView!

    private var wasPlaying = false
    private var player: AVPlayer! {playerController.player}
    private var asset: AVAsset!
    var optputURL : URL?
    var finalURL : ((URL) -> Void)?

    // MARK: - Input
    @objc private func didBeginTrimming(_ sender: VideoTrimmer) {
        updateLabels()

        wasPlaying = (player.timeControlStatus != .paused)
        player.pause()

        updatePlayerAsset()
    }

    @objc private func didEndTrimming(_ sender: VideoTrimmer) {
        updateLabels()

        if wasPlaying == true {
            player.play()
        }

        updatePlayerAsset()
    }

    @objc private func selectedRangeDidChanged(_ sender: VideoTrimmer) {
        updateLabels()
    }

    @objc private func didBeginScrubbing(_ sender: VideoTrimmer) {
        updateLabels()

        wasPlaying = (player.timeControlStatus != .paused)
        player.pause()
    }

    @objc private func didEndScrubbing(_ sender: VideoTrimmer) {
        updateLabels()

        if wasPlaying == true {
            player.play()
        }
    }

    @objc private func progressDidChanged(_ sender: VideoTrimmer) {
        updateLabels()

        let time = CMTimeSubtract(trimmer.progress, trimmer.selectedRange.start)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    // MARK: - Private
    private func updateLabels() {
        lblStartTime.text = trimmer.selectedRange.start.displayString
//        currentTimeLabel.text = trimmer.progress.displayString
        lblEndTime.text = trimmer.selectedRange.end.displayString
    }

    private func updatePlayerAsset() {
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset.fullRange
        let trimmedAsset = asset.trimmedComposition(outputRange)
        if trimmedAsset != player.currentItem?.asset {
            player.replaceCurrentItem(with: AVPlayerItem(asset: trimmedAsset))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        asset = AVURLAsset(url: optputURL!, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])

        playerController.player = AVPlayer()
        playerController.view.backgroundColor = UIColor(red: 45/255, green: 55/255, blue: 70/255, alpha: 1)
        addChild(playerController)
        viewPlay.addSubview(playerController.view)
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerController.view.leadingAnchor.constraint(equalTo: viewPlay.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: viewPlay.trailingAnchor),
            playerController.view.topAnchor.constraint(equalTo: viewPlay.topAnchor),
            playerController.view.bottomAnchor.constraint(equalTo: viewPlay.bottomAnchor),
//            playerController.view.heightAnchor.constraint(equalTo: viewPlay.widthAnchor, multiplier: 720 / 1280)
        ])

        // THIS IS WHERE WE SETUP THE VIDEOTRIMMER:
        trimmer = VideoTrimmer()
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: VideoTrimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: VideoTrimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: VideoTrimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: VideoTrimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: VideoTrimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: VideoTrimmer.progressChanged)
        viewTrim.addSubview(trimmer)
        trimmer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trimmer.leadingAnchor.constraint(equalTo: viewTrim.leadingAnchor),
            trimmer.trailingAnchor.constraint(equalTo: viewTrim.trailingAnchor),
            trimmer.topAnchor.constraint(equalTo: viewTrim.topAnchor, constant: 0),
            trimmer.heightAnchor.constraint(equalToConstant: 50),
        ])

        trimmer.asset = asset
        updatePlayerAsset()

        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self = self else {return}
            let finalTime = self.trimmer.trimmingState == .none ? CMTimeAdd(time, self.trimmer.selectedRange.start) : time
            self.trimmer.progress = finalTime
        }
        updateLabels()
    }
    
    @IBAction func actionSave(_ sender: UIButton) {
        SVProgressHUD.show()
        let sourceURL = optputURL!
        let startTime = CMTimeGetSeconds(trimmer.selectedRange.start)
        let endTime = CMTimeGetSeconds(trimmer.selectedRange.end)

        trimVideo(sourceURL: sourceURL, startTime: startTime, endTime: endTime) { outputURL, error in
            if let outputURL = outputURL {
                SVProgressHUD.dismiss()
                print("Trimmed video URL: \(outputURL)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.finalURL?(outputURL)
                    }
                }
            } else if let error = error {
                // Handle error
                SVProgressHUD.dismiss()
                print("Error trimming video: \(error.localizedDescription)")
            }
        }
    }
    
    func trimVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVURLAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil, NSError(domain: "TrimVideoErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"]))
            return
        }

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        let startTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let endTime = CMTime(seconds: endTime, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)

        exportSession.timeRange = timeRange

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL, nil)
            case .failed:
                completion(nil, exportSession.error)
            case .cancelled:
                completion(nil, NSError(domain: "TrimVideoErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Export session cancelled"]))
            default:
                break
            }
        }
    }
}
