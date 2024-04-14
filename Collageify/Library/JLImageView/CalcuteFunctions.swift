//
//  CalcuteFunctions.swift
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

import Foundation
import UIKit

class CalculateFunctions {
    static func CGRectGetCenter(_ rect: CGRect) -> CGPoint{
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    static func CGRectScale(_ rect: CGRect, wScale: CGFloat, hScale: CGFloat) -> CGRect {
        return CGRect(x: rect.origin.x * wScale, y: rect.origin.y * hScale, width: rect.size.width * wScale, height: rect.size.height * hScale)
    }
    
    static func CGpointGetDistance(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        let fx = point2.x - point1.x
        let fy = point2.y - point1.y
        
        return sqrt((fx * fx + fy * fy))
    }
    
    static func CGAffineTrasformGetAngle(_ t: CGAffineTransform) -> CGFloat{
        return atan2(t.b, t.a)
    }
    
    static func CGAffineTransformGetScale(_ t: CGAffineTransform) -> CGSize {
        return CGSize(width: sqrt(t.a * t.a + t.c + t.c), height: sqrt(t.b * t.b + t.d * t.d))
    }
    
}
