//
//  Song.swift
//  MusicPlayer
//
//  Created by Sai Kambampati on 5/30/20.
//  Copyright © 2020 Sai Kambmapati. All rights reserved.
//

import Foundation

struct Song {
    var id: String
    var name: String
    var artistNamee: String
    var artworkURL: String
    var songURL: String

    init(id: String, name: String, artistNamee: String, artworkURL: String, songURL: String) {
        self.id = id
        self.name = name
        self.artworkURL = artworkURL
        self.artistNamee = artistNamee
        self.songURL = songURL
    }
}

struct SearchArtist {
    var id: String
    var artistNamee: String
    var artworkURL: String
    var url: String

    init(id: String, artistNamee: String, artworkURL: String, url: String) {
        self.id = id
        self.artworkURL = artworkURL
        self.artistNamee = artistNamee
        self.url = url
    }
}

struct SearchAlbums {
    
    var id: String
    var title: String
    var artistName: String
    var artworkURL: String
    var url: String

    init(id: String, title: String, artistName: String, artworkURL: String, url: String) {
        self.id = id
        self.title = title
        self.artworkURL = artworkURL
        self.artistName = artistName
        self.url = url
    }
}
