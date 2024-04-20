//
//  UIView+Helper.swift
//  OpalImagePicker
//
//  Created by Kristos Katsanevas on 9/30/17.
//  Copyright © 2017 Opal Orange LLC. All rights reserved.
//

import UIKit

extension UIView {
    
    func constraintsToFill(otherView: Any) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: otherView, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: otherView, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: otherView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: otherView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        ]
    }
    
    func constraintsToCenter(otherView: Any) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: otherView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: otherView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ]
    }
    
    func constraintEqualTo(with otherView: Any, attribute: NSLayoutConstraint.Attribute, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: otherView, attribute: attribute, multiplier: 1.0, constant: constant)
    }
    
    func constraintEqualTo(with otherView: Any, receiverAttribute: NSLayoutConstraint.Attribute, otherAttribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: receiverAttribute, relatedBy: .equal, toItem: otherView, attribute: otherAttribute, multiplier: 1.0, constant: 0.0)
    }
}

extension UIView {

    private func standardizeRect(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
    }

    var left: CGFloat {
        get {
            return frame.minX
        }
        set(x) {
            var frame = standardizeRect(self.frame)

            frame.origin.x = x
            self.frame = frame
        }
    }

    var top: CGFloat {
        get {
            return frame.minY
        }
        set(y) {
            var frame = standardizeRect(self.frame)

            frame.origin.y = y
            self.frame = frame
        }
    }

    var right: CGFloat {
        get {
            return frame.maxX
        }
        set(right) {
            var frame = standardizeRect(self.frame)

            frame.origin.x = right - frame.size.width
            self.frame = frame
        }
    }

    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set(bottom) {
            var frame = standardizeRect(self.frame)

            frame.origin.y = bottom - frame.size.height
            self.frame = frame
        }
    }

    var width: CGFloat {
        get {
            return frame.width
        }
        set(width) {
            var frame = standardizeRect(self.frame)

            frame.size.width = width
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return frame.height
        }
        set(height) {
            var frame = standardizeRect(self.frame)

            frame.size.height = height
            self.frame = frame
        }
    }

    var centerX: CGFloat {
        get {
            return frame.midX
        }
        set(centerX) {
            center = CGPoint(x: centerX, y: center.y)
        }
    }

    var centerY: CGFloat {
        get {
            return center.y
        }
        set(centerY) {
            center = CGPoint(x: center.x, y: centerY)
        }
    }

    var sizee: CGSize {
        get {
            return standardizeRect(frame).size
        }
        set(size) {
            var frame = standardizeRect(self.frame)

            frame.size = size
            self.frame = frame
        }
    }
}
