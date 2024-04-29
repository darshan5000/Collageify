//
//  Global.swift
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//


import UIKit


var userDefault = UserDefaults.standard
var arrOfFontType = ["Avenir Next","Bucanera", "champignonaltswash", "Dohearts", "Enjoy Personal Use", "Ginga>", "Granada Blues Personal Use", "LittleLordFontleroyNF", "Mf Gradient Goddess", "Miama", "Montez", "Playball", "PlumScript", "Pretty Girls Script Demo", "QuigleyWiggly", "Script Writing", "The Heart of Everything Demo", "Variane Script", "VTC-BadTattooHandOne", "VTKS SummerLAnd", "Waltograph", "Allura-Regular", "Alleana Script", "Aguafina Script", "Advertising Script Monoline", "Advertising Script", "Adine Kirnberg", "a Theme for murder","Alex Brush","akaDora","ALS Script","Arizonia"]

var arrOfFont = ["Normal", "Bold", "Italic", "Bold Italic"]

var arrOfMain = ["Layout", "background", "text", "stickers", "fx"]
var arrOfSingleMain = ["text", "stickers", "fx", "filter"]

var arrOfFx = ["fxo_0", "fxo_1", "fxo_2", "fxo_3", "fxo_4", "fxo_5", "fxo_6", "fxo_7", "fxo_8", "fxo_9", "fxo_10", "fxo_11", "fxo_12", "fxo_13", "fxo_14", "fxo_15", "fxo_16", "fxo_17", "fxo_18"]

//var arrOfStickersItems = ["couple_0", "feather", "heart","butterfly", "love", "bubble", "cool", "smile"]
var arrOfStickersItems = ["love"]

var arrOfFilter = ["Normal", "Chrome", "Fade", "Instant", "Mono", "Noir",  "Process", "Tonal", "Transfer" , "Tone", "Sepia", "Blur", "Exposure", "Vignette", "Red", "Sharpen", "Invert"]

var arrOfIndex = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60]

var val = CGAffineTransform(scaleX: 1, y: 1)
var value1 = CGAffineTransform(scaleX: -1, y: 1)
var value2 = CGAffineTransform(scaleX: 1, y: -1)
var value3 = CGAffineTransform(scaleX: -1, y: -1)

var IS_ADS_SHOW: Bool = true
var REEL_COUNT: Int = 0
var CLICK_COUNT: Int = 0

func setView(view: UIView) {
    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
    })
}

extension UIButton {
    
    private class Action {
        var action: (UIButton) -> Void
        
        init(action: @escaping (UIButton) -> Void) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var ActionTapped = "actionTapped"
        static var ActionTappedIO = "actionTappedIO"
    }
    
    private var tapAction: Action? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionTapped, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionTapped) as? Action }
    }
    
    private var tapActionIO: Action? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionTappedIO, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionTappedIO) as? Action }
    }
    
    @objc dynamic private func handleAction(_ recognizer: UIButton) {
        tapAction?.action(recognizer)
    }
    
    @objc dynamic private func handleActionIO(_ recognizer: UIButton) {
        Timer.after(0.22) {
            self.tapActionIO?.action(recognizer)
        }
    }
    
    func mk_addTapHandler(action: @escaping (UIButton) -> Void) {
        self.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
        tapAction = Action(action: action)
    }
    
    func mk_addTapHandlerIO(action: @escaping (UIButton) -> Void) {
        (self as? PressButton)?.animate(onPress: true)
        self.addTarget(self, action: #selector(handleActionIO(_:)), for: .touchUpInside)
        tapActionIO = Action(action: action)
    }
}

extension UIImage {
    
    func fixedOrientation() -> UIImage? {
        
        guard imageOrientation != UIImage.Orientation.up else {
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .leftMirrored)
    }
    
}

extension UIColor {
    static let backColor = UIColor(red: 43/255, green: 55/255, blue: 71/255, alpha: 1)
    
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension Array {
    func toPoint(size: CGSize, padding: CGFloat) -> [CGPoint] {
        var cg = [CGPoint]()
        self.forEach { e in
            guard let pt = e as? [CGFloat], let p1 = pt.first else {return}
            let p2 = pt[1]
//            let p3: CGFloat = pt[2]*padding
//            let p4: CGFloat = pt[3]*padding
//            cg.append(CGPoint(x: (p1*size.width)+p3, y: (p2*size.height)+p4))
            cg.append(CGPoint(x: p1*size.width, y: p2*size.height))
        }
        return cg
    }
    
    func toRect(size: CGSize) -> CGRect {
        var cg = CGRect.zero
        guard let pt = self as? [CGFloat] else {return cg}
        let p1: CGFloat = pt[0]
        let p2: CGFloat = pt[1]
        let p3: CGFloat = pt[2]
        let p4: CGFloat = pt[3]
        cg = CGRect(x: p1*size.width, y: p2*size.height, width: p3*size.width, height: p4*size.height)
        return cg
    }
    
    func toPoint(rect: CGRect, defaultV: CGFloat = 10) -> CGPoint {
        var cg = CGPoint.zero
        guard let pt = self as? [CGFloat], let p1 = pt.first else {return cg}
        let p2 = pt[1]
        if p1 == defaultV {
            cg = CGPoint(x: p1, y: (p2*rect.maxY))
        } else if p2 == defaultV {
            cg = CGPoint(x: (p1*rect.maxX), y: p2)
        } else {
            cg = CGPoint(x: (p1*rect.maxX), y: (p2*rect.maxY))
        }
        
        return cg
    }
    
    func toPointC(rect: CGRect, padding: CGFloat) -> [CGPoint] {
        var cg = [CGPoint]()
        self.forEach { e in
            guard let pt = e as? [CGFloat], let p1 = pt.first else {return}
            let p2 = pt[1]
            let p3: CGFloat = pt[2]*padding
            let p4: CGFloat = pt[3]*padding
            cg.append(CGPoint(x: (p1*rect.size.width)+p3, y: (p2*rect.size.height)+p4))
            //            cg.append(CGPoint(x: (p1*rect.maxX)+p3, y: (p2*rect.maxY)+p4))
            //            cg.append(CGPoint(x: p1*size.width, y: p2*size.height))
        }
        return cg
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}
