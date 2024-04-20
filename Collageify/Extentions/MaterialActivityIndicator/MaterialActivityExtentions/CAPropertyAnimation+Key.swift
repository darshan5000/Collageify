//
//  CAPropertyAnimation+Key.swift
//  MaterialActivityIndicator
//
//  Created by Jans Pavlovs on 15.02.18.
//  Copyright (c) 2018 Jans Pavlovs. All rights reserved.
//

import UIKit

extension CAPropertyAnimation {
    enum Key: String {
        var path: String {
            return rawValue
        }

        case strokeStart
        case strokeEnd
        case strokeColor
        case rotationZ = "transform.rotation.z"
        case scale = "transform.scale"
    }

    convenience init(key: Key) {
        self.init(keyPath: key.path)
    }
}
