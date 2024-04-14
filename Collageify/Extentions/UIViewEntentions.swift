//
//  UIViewEntentions.swift
//  CollageMaker
//
//  Created by M!L@N on 28/02/24.
//  Copyright © 2024 iMac. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setConstraintsXYWH(att1: [NSLayoutConstraint.Attribute], view2: [UIView?], att2: [NSLayoutConstraint.Attribute]? = nil, constants: [CGFloat], multipliers: [CGFloat] = [1,1,1,1,1,1,1,1], priority: [UILayoutPriority]? = nil, safeaArea: [Bool]? = nil, withTab: Bool = true, autoScale: Bool = false) {
        
        translatesAutoresizingMaskIntoConstraints = false
        var att = [NSLayoutConstraint.Attribute]()
        if att2 == nil {
            att = att1
        } else {
            att = att2!
        }
        
        for index in 0..<att1.count {
            var cons: NSLayoutConstraint!
            let const = constants[index]
            
            if let safeaArea = safeaArea {
                if safeaArea[index] {
                    let margins = view2[index]!.safeAreaLayoutGuide
                    if att1[index] == .centerX {
                        cons = self.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: const)
                    }
                    if att1[index] == .leading {
                        cons = self.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: const)
                    }
                    if att1[index] == .trailing {
                        cons = self.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: const)
                    }
                    if att1[index] == .top {
                        cons = self.topAnchor.constraint(equalTo: margins.topAnchor, constant: const)
                    }
                    if att1[index] == .bottom {
                        cons = self.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: const)
                        //                        printLog("Tabbar Height === ", findViewController()?.tabBarcontroller?.tabbarHeight ?? 0)
                        //                        cons = self.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -((withTab ? (findViewController()?.tabBarcontroller?.tabbarHeight ?? 0) : 0) + const))
                    }
                } else {
                    cons = NSLayoutConstraint(item: self, attribute: att1[index], relatedBy: .equal, toItem: view2[index], attribute: att[index], multiplier: multipliers[index], constant: const)
                }
            } else {
                cons = NSLayoutConstraint(item: self, attribute: att1[index], relatedBy: .equal, toItem: view2[index], attribute: att[index], multiplier: multipliers[index], constant: const)
            }
            
            if let p = priority {
                cons.priority = p[index]
            }
            
            cons.isActive = true
        }
    }
    
    func setSize(width: CGFloat, height: CGFloat) {
        self.setConstraintsXYWH(att1: [.width, .height], view2: [nil, nil], att2: [.notAnAttribute, .notAnAttribute], constants: [width, height])
    }
    
    func setHeight(height: CGFloat, priority: UILayoutPriority? = nil) {
        self.setConstraintsXYWH(att1: [.height], view2: [nil], att2: [.notAnAttribute], constants: [height], priority: priority == nil ?  nil : [priority!])
    }
    
    func setWidth(width: CGFloat, priority: UILayoutPriority? = nil) {
        self.setConstraintsXYWH(att1: [.width], view2: [nil], att2: [.notAnAttribute], constants: [width], priority: priority == nil ?  nil : [priority!])
    }
    
    func updateConstraintConstantSuper(firstAttribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        
        let c = superview!.constraints.filter({ $0.firstAttribute == firstAttribute && $0.firstItem as! UIView == self })
        
        if !c.isEmpty {
            c.first!.constant = constant
        }
    }
    
    func updateConstraintConstantSelf(firstAttribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        
        let c = self.constraints.filter({
            $0.firstAttribute == firstAttribute &&
            $0.firstItem as! UIView == self })
        
        _ = c.map {$0.constant = constant}
    }
    
    func updateConstraintConstantSelfForSafeArea(firstAttribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        
        let c = self.constraints.filter({
            $0.firstAttribute == firstAttribute })
        
        _ = c.map {$0.constant = constant}
    }
    
    func fillSuperview() {
        
        translatesAutoresizingMaskIntoConstraints = false
        guard let s = superview else {
            print("super view not found")
            return }
        setConstraintsXYWH(att1: [.leading, .trailing, .top, .bottom], view2: [s,s,s,s], constants: [0,0,0,0])
    }
    
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}
