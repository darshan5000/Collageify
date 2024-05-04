//
//  VideoManager.swift
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVKit

struct VideoData {
    var index:Int?
    var image:UIImage?
    var asset:AVAsset?
    var isVideo = false
}

struct TextData {
    var text = ""
    var fontSize:CGFloat = 40
    var textColor = UIColor.red
    var showTime:CGFloat = 0
    var endTime:CGFloat = 0
    var textFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
}

var audioUrl : URL?

class VideoManager {
    static let shared = VideoManager()

    let defaultSize = CGSize(width: 828.0, height: 1792.0)
    var imageDuration = 4.0 // Duration of each image

    
    typealias Completion = (URL?, Error?) -> Void
    
    func makeVideoFrom(data:[VideoData], completion:@escaping Completion) -> Void {
        
        var insertTime = CMTime.zero
        var arrayLayerInstructions:[AVMutableVideoCompositionLayerInstruction] = []
        var arrayLayerImages:[CALayer] = []
        
        // Black background video
        guard let bgVideoURL = Bundle.main.url(forResource: "black", withExtension: "mov") else {
            print("Need black background video !")
            completion(nil,nil)
            return
        }
        
        let bgVideoAsset = AVAsset(url: bgVideoURL)
        guard let bgVideoTrack = bgVideoAsset.tracks(withMediaType: AVMediaType.video).first else {
            print("Need black background video !")
            completion(nil,nil)
            return
        }
        
        if audioUrl == nil {
            // Silence sound (in case video has no sound track)
            guard let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
                print("Missing resource")
                completion(nil, nil)
                return
            }
            audioUrl = silenceURL
        }
        
        let silenceAsset = AVAsset(url: audioUrl!)
        let silenceSoundTrack = silenceAsset.tracks(withMediaType: AVMediaType.audio).first
        
        // Init composition
        let mixComposition = AVMutableComposition()

        // Merge
        for videoData in data {
            
            if videoData.isVideo {
                guard let videoAsset = videoData.asset else { continue }
                
                // Get video track
                guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }
                
                // Get audio track
                var audioTrack:AVAssetTrack?
//                if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
//                    audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
//                } else {
                    audioTrack = silenceSoundTrack
//                }
                
                // Init video & audio composition track
                let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                
                let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                
                do {
                    let startTime = CMTime.zero
                    let duration = videoAsset.duration
                    
                    // Add video track to video composition at specific time
                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration), of: videoTrack, at: insertTime)
                    
                    // Add audio track to audio composition at specific time
                    if let audioTrack = audioTrack {
                        try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: insertTime, duration: duration), of: audioTrack, at: insertTime)
                    }
                    
                    // Add instruction for video track
                    if let videoCompositionTrack = videoCompositionTrack {
                        let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack, asset: videoAsset, targetSize: defaultSize)
                        
                        // Hide video track before changing to new track
                        let endTime = CMTimeAdd(insertTime, duration)
                        let durationAnimation = 1.0.toCMTime()
                        
                        layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange.init(start: endTime, duration: durationAnimation))
                        
                        arrayLayerInstructions.append(layerInstruction)
                    }
                    
                    // Increase the insert time
                    insertTime = CMTimeAdd(insertTime, duration)
                } catch {
                    print("Load track error")
                }
            } else { // Image
                let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                
                let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                
                let itemDuration = imageDuration.toCMTime()

                do {
                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: insertTime, duration: itemDuration), of: bgVideoTrack, at: insertTime)
                    
                    // Add audio track to audio composition at specific time
                    if let audioTrack = silenceSoundTrack {
                        try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: insertTime, duration: itemDuration), of: audioTrack, at: insertTime)
                    }
                } catch {
                    print("Load background track error")
                }
                
                // Create Image layer
                guard let image = videoData.image else { continue }
                
                let ratio = image.size.width / image.size.height
                let imageHeight = defaultSize.height / ratio
                let imageWidth = defaultSize.width
//                let size = CGSize(width: 414, height: 191)
                
                let imageLayer = CALayer()
//                imageLayer.contentsCenter = CGRect(x: 0, y: ((defaultSize.height / 2) - (imageHeight / 2)), width: imageWidth, height: imageHeight)
                imageLayer.frame = CGRect(x: 0, y: 0, width: defaultSize.width, height: defaultSize.height)
                imageLayer.contents = image.cgImage
                imageLayer.opacity = 0
                imageLayer.contentsGravity = CALayerContentsGravity.resizeAspect
                
                setOrientation(image: image, onLayer: imageLayer, outputSize: image.size)
                
                // Add Fade in & Fade out animation
                let fadeInAnimation = CABasicAnimation.init(keyPath: "opacity")
                fadeInAnimation.duration = 0
                fadeInAnimation.fromValue = NSNumber(value: 0)
                fadeInAnimation.toValue = NSNumber(value: 1)
                fadeInAnimation.isRemovedOnCompletion = false
                fadeInAnimation.beginTime = insertTime.seconds == 0 ? 0.05: insertTime.seconds
                fadeInAnimation.fillMode = CAMediaTimingFillMode.forwards
                imageLayer.add(fadeInAnimation, forKey: "opacityIN")
                
                let fadeOutAnimation = CABasicAnimation.init(keyPath: "opacity")
                fadeOutAnimation.duration = 0
                fadeOutAnimation.fromValue = NSNumber(value: 1)
                fadeOutAnimation.toValue = NSNumber(value: 0)
                fadeOutAnimation.isRemovedOnCompletion = false
                fadeOutAnimation.beginTime = CMTimeAdd(insertTime, itemDuration).seconds
                fadeOutAnimation.fillMode = CAMediaTimingFillMode.forwards
                imageLayer.add(fadeOutAnimation, forKey: "opacityOUT")
                
                arrayLayerImages.append(imageLayer)
                
                // Increase the insert time
                insertTime = CMTimeAdd(insertTime, itemDuration)
            }
        }
        
        // Init Video layer
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: defaultSize.width, height: defaultSize.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: defaultSize.width, height: defaultSize.height)
        parentlayer.addSublayer(videoLayer)
        
        // Add Image layers
        for layer in arrayLayerImages {
            parentlayer.addSublayer(layer)
        }
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mainComposition.renderSize = defaultSize
        mainComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentlayer)
        
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)
        
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = false
        exporter?.videoComposition = mainComposition
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                audioUrl = nil
                self.exportDidFinish(exporter: exporter, videoURL: exportURL, completion: completion)
            }
        })
    }
    
//    func exportMergedVideoWithImagesAndVideos(data: [VideoData], outputURL: URL, completion: @escaping (Error?) -> Void) {
//
//        let composition = AVMutableComposition()
//        var insertTime = CMTime.zero
//
//        // Track IDs for videos and images
//        var videoTrackIDs = [CMPersistentTrackID]()
//        var imageTrackIDs = [CMPersistentTrackID]()
//
//        // Merge
//        for videoData in data {
//
//            if videoData.isVideo {
//                guard let videoAsset = videoData.asset else { continue }
//
//                // Get video track
//                guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }
//                let videoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
//                // Add audio track to audio composition at specific time
//
//                guard let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first else {
//                    completion(nil)
//                    return
//                }
//
//                do {
//                    let startTime = CMTime.zero
//                    let duration = videoAsset.duration
//                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: videoTrack, at: insertTime)
//                    videoTrackIDs.append(videoCompositionTrack?.trackID ?? 0)
//                } catch {
//                    completion(nil)
//                    return
//                }
//            } else {
//                let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//
//                let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//
//                let itemDuration = imageDuration.toCMTime()
//
//                do {
//                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: insertTime, duration: itemDuration), of: bgVideoTrack, at: insertTime)
//
//                    // Add audio track to audio composition at specific time
//                    if let audioTrack = silenceSoundTrack {
//                        try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: insertTime, duration: itemDuration), of: audioTrack, at: insertTime)
//                    }
//                } catch {
//                    print("Load background track error")
//                }
//
//                let imageAsset = AVAsset(image: image)
//                guard let imageTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
//                    completion(nil)
//                    return
//                }
//
//                let imageDuration = CMTime(seconds: 5, preferredTimescale: 600) // 5 seconds
//
//                guard let imageAssetTrack = imageAsset.tracks(withMediaType: .video).first else {
//                    completion(nil)
//                    return
//                }
//
//                do {
//                    try imageTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: imageDuration), of: imageAssetTrack, at: CMTime.zero)
//                    imageTrackIDs.append(imageTrack.trackID)
//                } catch {
//                    completion(nil)
//                    return
//                }
//            }
//        }
//
//        // Create a video composition instruction
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
//
//        var layerInstructions = [AVMutableVideoCompositionLayerInstruction]()
//
//        // Add video tracks instructions
//        for trackID in videoTrackIDs {
//            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: composition.track(withTrackID: trackID)!)
//            layerInstructions.append(layerInstruction)
//        }
//
//        // Add image tracks instructions with animation
//        var timeOffset = CMTime.zero
//        for trackID in imageTrackIDs {
//            let imageTrack = composition.track(withTrackID: trackID)!
//
//            // Create layer instruction for the image track
//            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: imageTrack)
//
//            // Apply scaling animation to the image
//            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//            scaleAnimation.fromValue = 0.5
//            scaleAnimation.toValue = 1.0
//            scaleAnimation.beginTime = CMTimeGetSeconds(timeOffset)
//            scaleAnimation.duration = CMTimeGetSeconds(imageTrack.timeRange.duration)
//
//            // Apply rotation animation to the image
//            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//            rotationAnimation.fromValue = 0
//            rotationAnimation.toValue = CGFloat.pi * 2
//            rotationAnimation.beginTime = CMTimeGetSeconds(timeOffset)
//            rotationAnimation.duration = CMTimeGetSeconds(imageTrack.timeRange.duration)
//
//            // Combine animations
//            let animationGroup = CAAnimationGroup()
//            animationGroup.animations = [scaleAnimation, rotationAnimation]
//            animationGroup.duration = CMTimeGetSeconds(imageTrack.timeRange.duration)
//            animationGroup.fillMode = .forwards
//            animationGroup.isRemovedOnCompletion = false
//
//            // Apply animation to the layer instruction
//            layerInstruction.setTransformRamp(fromStart: CGAffineTransform(scaleX: 0.5, y: 0.5), toEnd: CGAffineTransform(scaleX: 1.0, y: 1.0), timeRange: imageTrack.timeRange)
//            layerInstruction.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: imageTrack.timeRange)
//            layerInstruction.setTransform(animationGroup.toValue, at: CMTimeRangeMake(start: imageTrack.timeRange.start, duration: imageTrack.timeRange.duration))
//
//            layerInstructions.append(layerInstruction)
//
//            // Increment the time offset for the next image track
//            timeOffset = CMTimeAdd(timeOffset, imageTrack.timeRange.duration)
//        }
//
//        instruction.layerInstructions = layerInstructions
//
//        // Create a video composition
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.instructions = [instruction]
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30) // 30 fps
//        videoComposition.renderSize = CGSize(width: 640, height: 480) // Adjust as needed
//
//        // Export the merged composition
//        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//            completion(nil)
//            return
//        }
//
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = .mp4
//        exportSession.videoComposition = videoComposition
//
//        exportSession.exportAsynchronously {
//            completion(exportSession.error)
//        }
//    }
}

// MARK:- Private methods
extension VideoManager {
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack?, asset: AVAsset, targetSize: CGSize) -> AVMutableVideoCompositionLayerInstruction {
        guard let track = track else {
            return AVMutableVideoCompositionLayerInstruction()
        }
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        let transform = assetTrack.fixedPreferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = targetSize.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            // Scale to fit target size
            scaleToFitRatio = targetSize.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // Align center Y
            let newY = targetSize.height/2 - (assetTrack.naturalSize.width * scaleToFitRatio)/2
            let moveCenterFactor = CGAffineTransform(translationX: 0, y: newY)
            
            let finalTransform = transform.concatenating(scaleFactor).concatenating(moveCenterFactor)

            instruction.setTransform(finalTransform, at: .zero)
        } else {
            // Scale to fit target size
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // Align center Y
            let newY = targetSize.height/2 - (assetTrack.naturalSize.height * scaleToFitRatio)/2
            let moveCenterFactor = CGAffineTransform(translationX: 0, y: newY)
            
            let finalTransform = transform.concatenating(scaleFactor).concatenating(moveCenterFactor)
            
            instruction.setTransform(finalTransform, at: .zero)
        }

        return instruction
    }
    
    private func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        
        switch [transform.a, transform.b, transform.c, transform.d] {
        case [0.0, 1.0, -1.0, 0.0]:
            assetOrientation = .right
            isPortrait = true
            
        case [0.0, -1.0, 1.0, 0.0]:
            assetOrientation = .left
            isPortrait = true
            
        case [1.0, 0.0, 0.0, 1.0]:
            assetOrientation = .up
            
        case [-1.0, 0.0, 0.0, -1.0]:
            assetOrientation = .down

        default:
            break
        }
    
        return (assetOrientation, isPortrait)
    }
    
    private func setOrientation(image:UIImage?, onLayer:CALayer, outputSize:CGSize) -> Void {
        guard let image = image else { return }

        if image.imageOrientation == UIImage.Orientation.up {
            // Do nothing
        }
        else if image.imageOrientation == UIImage.Orientation.left {
            let rotate = CGAffineTransform(rotationAngle: .pi/2)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImage.Orientation.down {
            let rotate = CGAffineTransform(rotationAngle: .pi)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImage.Orientation.right {
            let rotate = CGAffineTransform(rotationAngle: -.pi/2)
            onLayer.setAffineTransform(rotate)
        }
    }
    
    private func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping Completion) -> Void {
        if exporter?.status == AVAssetExportSession.Status.completed {
            print("Exported file: \(videoURL.absoluteString)")
            completion(videoURL,nil)
        }
        else if exporter?.status == AVAssetExportSession.Status.failed {
            completion(videoURL,exporter?.error)
        }
    }
}
