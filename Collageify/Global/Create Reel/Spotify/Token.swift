//
//  Token.swift
//  SpotyTest
//
//  Created by M!L@N on 16/04/24.
//  Copyright © 2024 David Zavala. All rights reserved.
//

import Foundation

let spotifyClientId = "9db9d70f366544969b5d3d470ae31581"
let spotifyClientSecret = "80c1119b268a419eb81bb014a961e692"

class SpotifyToken: NSObject {
    
    var currentToken: String?
    
    init(object: String) {
        super.init()
        self.update(object: object)
    }
    
    func update(object: String) {
        currentToken = object
    }
    
    static func currentToken() -> String? {
        if let data = UserDefaults.standard.object(forKey: "Token") as? String, !data.isEmpty {
            return data
        }
        return nil
    }
    
    static func isAvailable() -> Bool {
        if let _ = currentToken() {
            return true
        }
        else {
            return false
        }
    }
    
    static func logout()
    {
        UserDefaults.standard.set(nil, forKey: "Token")
        UserDefaults.standard.synchronize()
    }
    
    func saveToDefaults() {
        UserDefaults.standard.set(currentToken, forKey: "Token")
        UserDefaults.standard.synchronize()
    }
}
