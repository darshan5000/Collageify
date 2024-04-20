//
//  VideoEditViewController.swift
//  CollageMaker
//
//  Created by M!L@N on 10/04/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation
import SVProgressHUD

class VideoEditViewController: UIViewController {

    @IBOutlet var viewVideoMain: UIView!
    @IBOutlet weak var viewTrimMain: UIView!
    
    private let viewVideo: VideoView = {
        let videoView = VideoView(viewType: .default)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        return videoView
    }()
    
    private let viewTrim: VideoTrim = {
        let videoTrim = VideoTrim()
        videoTrim.translatesAutoresizingMaskIntoConstraints = false
        videoTrim.topMargin = 4
        videoTrim.bottomMargin = 8
        return videoTrim
    }()
    
    var videoAsset : VideoData?
    private var videoConverter: VideoConverter?
    private var isPlaying = false
    private var rotate: Double = 0
    private var preset: String?
    var actionAssetDone : ((_ data: AVAsset) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewVideoMain.addSubview(self.viewVideo)
        self.viewTrimMain.addSubview(self.viewTrim)
        self.viewVideoMain.addConstraints([
            NSLayoutConstraint(item: self.viewVideo, attribute: .top, relatedBy: .equal, toItem: self.viewVideoMain, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewVideo, attribute: .top, relatedBy: .equal, toItem: self.viewVideoMain, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewVideo, attribute: .leading, relatedBy: .equal, toItem: self.viewVideoMain, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewVideo, attribute: .trailing, relatedBy: .equal, toItem: self.viewVideoMain, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        
        self.viewTrimMain.addConstraints([
            NSLayoutConstraint(item: self.viewTrim, attribute: .top, relatedBy: .equal, toItem: self.viewTrimMain, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewTrim, attribute: .top, relatedBy: .equal, toItem: self.viewTrimMain, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewTrim, attribute: .leading, relatedBy: .equal, toItem: self.viewTrimMain, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.viewTrim, attribute: .trailing, relatedBy: .equal, toItem: self.viewTrimMain, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        
        viewTrim.topMargin = 4
        viewTrim.bottomMargin = 8
        
        self.viewVideo.delegate = self
        self.viewTrim.delegate = self
        assetURL(for: videoAsset?.asset ?? AVAsset())
        
        self.preset = nil
        self.rotate = 0
        self.viewVideo.containerView.transform = CGAffineTransform.identity
        self.viewVideo.degree = 0
        self.viewTrim.asset = videoAsset?.asset
        self.viewVideo.restoreCrop()
        self.videoConverter = VideoConverter(asset: videoAsset?.asset ?? AVAsset())
        self.updateTrimTime()
        viewVideo.setupFrame(height: viewVideoMain.bounds.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.viewVideo.invalidate()
    }
    
    func assetURL(for asset: AVAsset) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        do {
            let filename = ProcessInfo.processInfo.globallyUniqueString
            let fileURL = temporaryDirectoryURL.appendingPathComponent("\(filename).mp4")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
            exporter?.outputURL = fileURL
            exporter?.outputFileType = .mp4

            exporter?.exportAsynchronously(completionHandler: {
                if exporter?.status == .completed {
                    print("Export completed successfully.")
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        self.viewVideo.url = fileURL
                        self.viewVideo.isMute = true
                    }
                } else if exporter?.status == .failed {
                    print("Export failed with error: \(exporter?.error?.localizedDescription ?? "Unknown error")")
                }
            })
        } catch {
            print("Error creating temporary file URL: \(error.localizedDescription)")
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionDone(_ sender: Any) {
        guard let videoConverter = self.videoConverter else { return }

        var videoConverterCrop: ConverterCrop?
        if let dimFrame = self.viewVideo.dimFrame {
            videoConverterCrop = ConverterCrop(frame: dimFrame, contrastSize: self.viewVideo.videoRect.size)
        }
        videoConverter.convert(ConverterOption(
            trimRange: CMTimeRange(start: self.viewTrim.startTime, duration: self.viewTrim.durationTime),
            convertCrop: videoConverterCrop,
            rotate: CGFloat(.pi/2 * self.rotate),
            quality: self.preset,
            isMute: true), progress: { [weak self] (progress) in
                SVProgressHUD.show()
            }, completion: { [weak self] (url, error) in
            if let error = error {
                let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
                self?.present(alertController, animated: true)
            } else {
                SVProgressHUD.dismiss()
                if let urll = url {
                    self?.dismiss(animated: true) {
                        let asset = AVAsset(url: urll)
                        self?.actionAssetDone?(asset)
                    }
                }
            }
        })
    }
}

// MARK: ViewController + Crop & Rotate
extension VideoEditViewController {
    
    @IBAction func actionRotate(_ sender: UIButton) {
        var transform = CGAffineTransform.identity
        self.rotate += 1
        if self.rotate == 4 {
            self.rotate = 0
            self.viewVideo.degree = 0
        } else {
            let rotate = CGFloat(.pi/2 * self.rotate)
            transform = transform.rotated(by: rotate)
            self.viewVideo.degree = rotate * 180 / CGFloat.pi
        }
        self.viewVideo.dimFrame = nil
        self.viewVideo.containerView.transform = transform
    }
    
    @IBAction func actionCrop(_ sender: UIButton) {
        guard let asset = self.viewVideo.player?.currentItem?.asset,
            let currentTime = self.viewVideo.player?.currentTime() else { return }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        guard let imageRef = try? imageGenerator.copyCGImage(at: currentTime, actualTime: nil) else { return }
        guard let image = UIImage(cgImage: imageRef).rotate(radians: Float(CGFloat(.pi/2 * self.rotate))) else { return }
        let viewController = CropViewController(image: image)
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: ViewController + CropDelegate
extension VideoEditViewController: CropDelegate {
    func cropImage(_ imageSize: CGSize, cropFrame: CGRect) {
        let videoRect = self.viewVideo.videoRect
        let frameX = cropFrame.origin.x * videoRect.size.width / imageSize.width
        let frameY = cropFrame.origin.y * videoRect.size.height / imageSize.height
        let frameWidth = cropFrame.size.width * videoRect.size.width / imageSize.width
        let frameHeight = cropFrame.size.height * videoRect.size.height / imageSize.height
        let dimFrame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        self.viewVideo.dimFrame = dimFrame
    }
}

// MARK: ViewController + Update Trim
extension VideoEditViewController {
    private func updateTrimTime() {
        self.viewVideo.startTime = self.viewTrim.startTime
        self.viewVideo.endTime = self.viewTrim.endTime
        self.viewVideo.durationTime = self.viewTrim.durationTime
    }
}

// MARK: ViewController + VideoDelegate
extension VideoEditViewController: VideoDelegate {
    func videoPlaying() {
        self.viewTrim.currentTime = self.viewVideo.player?.currentTime()
    }
}

// MARK: ViewController + VideoTrimDelegate
extension VideoEditViewController: VideoTrimDelegate {
    func videoTrimStartTrimChange(_ view: VideoTrim) {
        self.isPlaying = self.viewVideo.isPlaying
        self.viewVideo.pause()
    }

    func videoTrimEndTrimChange(_ view: VideoTrim) {
        self.updateTrimTime()
        if self.isPlaying {
            self.viewVideo.play()
        }
    }

    func videoTrimPlayTimeChange(_ view: VideoTrim) {
        self.viewVideo.player?.seek(to: CMTime(value: CMTimeValue(view.playTime.value + view.startTime.value), timescale: view.playTime.timescale))
        self.updateTrimTime()
    }
}
