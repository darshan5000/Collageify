//
//  AppleMusicAPI.swift
//  Manage_My_Playlists
//
//  Created by Aisultan Askarov on 6.01.2023.
//

import UIKit
import StoreKit
import MusicKit
import MediaPlayer

struct LibraryElementsStructure: Identifiable {
    
    let id: String = UUID().uuidString
    var title: String
    var icon: String
}

struct PlaylistWithMusicStructure {
        
    var Playlist: Playlist?
    var Tracks: [Track?]
    var PlayParams: MPMusicPlayerPlayParameters?
    
}

class AppleMusicAPI {
    
    static let shared = AppleMusicAPI()
    let mediaServiceController = SKCloudServiceController()
    var playlistsArray = [PlaylistWithMusicStructure]()
    var storeFrontId: String = ""
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    private init() {}
    
    func checkIfAppleMusicIsAvailable(onCompletion: @escaping (MediaRequestResultReferences?) -> Void) {
                
        DispatchQueue.global(qos: .background).async {
            
            if SKCloudServiceController.authorizationStatus() == .authorized {
                
                onCompletion(.authorized)
                
            } else if SKCloudServiceController.authorizationStatus() == .denied {
                
                onCompletion(.denied)
                
            } else if SKCloudServiceController.authorizationStatus() == .notDetermined {
                
                onCompletion(.notDetermined)
                
            } else if SKCloudServiceController.authorizationStatus() == .restricted {
                onCompletion(.restricted)
            }
        }
    }
    
    func checkIfUserHasAppleMusicSubscription(onCompletion: @escaping (FetchResults?) -> Void) {
        
        DispatchQueue.global(qos: .background).async { [self] in
            mediaServiceController.requestCapabilities { capabilities, error in
                if capabilities.contains(.musicCatalogPlayback) {
                    // User has Apple Music account
                    onCompletion(.SUCCESS)
                }
                else if capabilities.contains(.musicCatalogSubscriptionEligible) {
                    // User can sign up to Apple Music
                    onCompletion(.FAILED)
                }
            }
        }
        
    }
    
    func appleMusicFetchStorefrontRegion(onCompletion: @escaping (FetchResults, String?) -> Void) {
        
        DispatchQueue.global(qos: .background).async { [self] in
            
            mediaServiceController.requestStorefrontIdentifier { storefrontId, error in
                
                DispatchQueue.main.async {
                    
                    guard error == nil else {
                        print("An error occured. Handle it here.")
                        onCompletion(.FAILED, nil)
                        return
                    }
                    
                    guard let storefrontId = storefrontId else {
                        print("Handle the error - the callback didn't contain a storefront ID.")
                        onCompletion(.FAILED, nil)
                        return
                    }
                    
                    let trimmedId = String(storefrontId.prefix(5))
                    self.storeFrontId = trimmedId
                    onCompletion(.SUCCESS, trimmedId)
                    
                    print("Success! The Storefront ID fetched was: \(trimmedId)")
                }
            }
        }
    }
    
//    func appleMusicFetchUsersPlaylists(onCompletion: @escaping (FetchResults, MusicItemCollection<Playlist>?) -> Void) {
//        
//        DispatchQueue.global(qos: .userInitiated).async { [self] in
//            
//            let schemeStruct = appleMusicFetchUsersPlaylistsScheme()
//
//            Task {
//                
//                var UsersPlaylistsURLComponents = URLComponents()
//                UsersPlaylistsURLComponents.scheme = schemeStruct.requestScheme
//                UsersPlaylistsURLComponents.host = schemeStruct.requestHost
//                UsersPlaylistsURLComponents.path = schemeStruct.requestPath
//                
//                if let url = UsersPlaylistsURLComponents.url {
//                    
//                    do {
//                        
//                        let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
//                        let playlistsResponse = try await dataRequest.response()
//                        
//                        let playlists = try? decoder.decode(MusicItemCollection<Playlist>.self, from: playlistsResponse.data)
//                        
//                        DispatchQueue.main.async {
//                            onCompletion(.SUCCESS, playlists)
//                        }
//                        
//                    } catch {
//                        print("Error Occured When fetching users playlists")
//                        DispatchQueue.main.async {
//                            onCompletion(.FAILED, nil)
//                        }
//                    }
//                }
//            }
//        }
//        
//    }
    
//    func appleMusicFetchPlaylistParameters(playlist_ids: MusicItemCollection<Playlist>, onCompletion: @escaping (FetchResults, [PlaylistWithMusicStructure]?) -> Void) {
//        
//        let schemeStruct = appleMusicFetchUsersPlaylistParametersScheme()
//
//        playlistsArray.removeAll()
//        
//        for playlist_id in playlist_ids {
//            
//            DispatchQueue.global(qos: .userInitiated).async { [self] in
//
//                Task {
//                    
//                    var UsersPlaylistParametersURLComponents = URLComponents()
//                    UsersPlaylistParametersURLComponents.scheme = schemeStruct.requestScheme
//                    UsersPlaylistParametersURLComponents.host = schemeStruct.requestHost
//                    UsersPlaylistParametersURLComponents.path = "\(schemeStruct.requestPath)/\(playlist_id.id)"
//                    
//                    if let url = UsersPlaylistParametersURLComponents.url {
//                        do {
//                            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
//                            let playlistsResponse = try await dataRequest.response()
//                            let playlist = try? decoder.decode(MusicItemCollection<Playlist>.self, from: playlistsResponse.data)
//                            
//                            let data = try? encoder.encode(playlist?.first?.playParameters)
//                            if data != nil {
//                                let playParams = try? decoder.decode(MPMusicPlayerPlayParameters.self, from: data!)
//                                DispatchQueue.main.async { [self] in
//                                playlistsArray.append(PlaylistWithMusicStructure(Playlist: playlist?.first ?? nil, Tracks: [Track?](), PlayParams: playParams ?? nil))
//                                    if playlistsArray.count == playlist_ids.count {
//                                        onCompletion(.SUCCESS, playlistsArray)
//                                    }
//                                }
//                                
//                            } else {
//                                DispatchQueue.main.async {
//                                    onCompletion(.FAILED, nil)
//                                }
//                            }
//                        } catch {
//                            print("Error Occured When fetching users playlists params")
//                            onCompletion(.FAILED, nil)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//    func appleMusicFetchMusicFromPlaylist(playlistId: String, storefrontId: String, onCompletion: @escaping (FetchResults, MusicItemCollection<Playlist>?) -> Void) {
//        
//        let schemeStruct = appleMusicFetchMusicFromPlaylistScheme()
//        
//        DispatchQueue.main.async { [self] in
//            
//            Task {
//                
//                var playlistTracksRequestURLComponents = URLComponents()
//                playlistTracksRequestURLComponents.scheme = schemeStruct.requestScheme
//                playlistTracksRequestURLComponents.host = schemeStruct.requestHost
//                playlistTracksRequestURLComponents.path = "\(schemeStruct.requestPath)/\(playlistId)"
//                playlistTracksRequestURLComponents.queryItems = schemeStruct.queryItems
//                
//                if let url = playlistTracksRequestURLComponents.url {
//                    do {
//                        let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
//                        let playlistsResponse = try await dataRequest.response()
//                        let playlist = try? decoder.decode(MusicItemCollection<Playlist>.self, from: playlistsResponse.data)
//                        
//                        DispatchQueue.main.async {
//                            if playlist != nil {
//                                onCompletion(.SUCCESS, playlist)
//                            } else {
//                                onCompletion(.FAILED, nil)
//                            }
//                        }
//                            
//                    } catch {
//                        print("Error Occured When fetching music from playlist")
//                        DispatchQueue.main.async {
//                            onCompletion(.FAILED, nil)
//                        }
//                    }
//                }
//                
//            }
//        }
//    }
    
    
    
    func appleArtistSearch(searchString: String, onCompletion: @escaping (FetchResults, [SearchArtist]?) -> Void) {
        
        Task {
            let currentLocale = Locale.current
            let regionCode = currentLocale.identifier.split(separator: "-").first

            if let regionCode = regionCode {
                print("Region code:", regionCode)
            } else {
                print("Could not extract region code")
            }

            var components = URLComponents()
            components.scheme = "https"
            components.host   = "api.music.apple.com"
            components.path   = "/v1/catalog/\(regionCode ?? "")/search"
            
            components.queryItems = [
                URLQueryItem(name: "term", value: searchString),
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "types", value: "artists"),
            ]
            
            if let url = components.url {
                do {
                    let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
                    let playlistsResponse = try await dataRequest.response()
                    var songs = [SearchArtist]()
                    if let json = try? JSON(data: playlistsResponse.data) {
                        let result = (json["results"]["artists"]["data"]).array ?? []
                        for song in result {
                            let attributes = song["attributes"]
                            let currentSong = SearchArtist(id: song["id"].string ?? "", artistNamee: attributes["name"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", url: attributes["url"].rawValue as? String ?? "")
                            songs.append(currentSong)
                        }
                    }
                    onCompletion(.SUCCESS, songs)
                } catch {
                    print("Error Occured When fetching music from playlist")
                    DispatchQueue.main.async {
                        onCompletion(.FAILED, nil)
                    }
                }
            }
        }
    }
    
    func appleGetAlbums(playlistId: String, onCompletion: @escaping (FetchResults, [Song]?) -> Void) {
        
        Task {
            var playlistRequestURLComponents = URLComponents()
            playlistRequestURLComponents.scheme = "https"
            playlistRequestURLComponents.host = "api.music.apple.com"
            playlistRequestURLComponents.path = "/v1/catalog/us/artists/\(playlistId)/albums"
            playlistRequestURLComponents.queryItems = [
                URLQueryItem(name: "limit", value: "100"),
            ]
            
            if let url = playlistRequestURLComponents.url {
                do {
                    let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
                    let playlistsResponse = try await dataRequest.response()
                    var songs = [Song]()
                    if let json = try? JSON(data: playlistsResponse.data) {
                        let result = (json["data"]).array ?? []
                        for song in result {
                            let attributes = song["attributes"]
                            let currentSong = Song(id: song["id"].string ?? "", name: attributes["name"].string ?? "", artistNamee: attributes["artistName"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", songURL: attributes["url"].rawValue as? String ?? "")
                            songs.append(currentSong)
                        }
                    }
                    onCompletion(.SUCCESS, songs)
                } catch {
                    print("Error Occured When fetching music from playlist")
                    DispatchQueue.main.async {
                        onCompletion(.FAILED, nil)
                    }
                }
            }
        }
    }
    
    func appleTracksByAlbum(playlistId: String, onCompletion: @escaping (FetchResults, [Song]?) -> Void) {
        let requestScheme = "https"
        let requestHost = "api.music.apple.com"
        let requestPath = "/v1/catalog/tr/playlists"
        let queryItems = [URLQueryItem(name: "include", value: "catalog")]
        Task {
            var playlistRequestURLComponents = URLComponents()
            playlistRequestURLComponents.scheme = "https"
            playlistRequestURLComponents.host = "api.music.apple.com"
            playlistRequestURLComponents.path = "/v1/catalog/us/albums/\(playlistId)"
//            playlistRequestURLComponents.queryItems = [
//                URLQueryItem(name: "include", value: "catalog"),
//                URLQueryItem(name: "limit", value: "100"),
////                URLQueryItem(name: "offset", value: String(offset)),
//            ]
            
            if let url = playlistRequestURLComponents.url {
                do {
                    let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
                    let playlistsResponse = try await dataRequest.response()
                    var songsArray = [Song]()
                    if let json = try? JSON(data: playlistsResponse.data) {
                        let result = (json["data"]).array ?? []
                        for data in result {
                            let songs = (data["relationships"]["tracks"]["data"]).array ?? []
                            for song in songs {
                                let attributes = song["attributes"]
                                let currentSong = Song(id: attributes["playParams"]["id"].string ?? "", name: attributes["name"].string ?? "", artistNamee: attributes["artistName"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", songURL: attributes["previews"][0]["url"].rawValue as? String ?? "")
                                songsArray.append(currentSong)
                            }
                        }
                    }
                    onCompletion(.SUCCESS, songsArray)
                } catch {
                    print("Error Occured When fetching music from playlist")
                    DispatchQueue.main.async {
                        onCompletion(.FAILED, nil)
                    }
                }
            }
        }
    }
    
    func appleMusicSearch(searchString: String, onCompletion: @escaping (FetchResults, [Song]?) -> Void) {
        
        Task {
            let currentLocale = Locale.current
            let regionCode = currentLocale.identifier.split(separator: "-").first

            if let regionCode = regionCode {
                print("Region code:", regionCode)
            } else {
                print("Could not extract region code")
            }
            
            var components = URLComponents()
            components.scheme = "https"
            components.host   = "api.music.apple.com"
            components.path   = "/v1/catalog/\(regionCode ?? "")/search"
            
            components.queryItems = [
                URLQueryItem(name: "term", value: searchString),
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "types", value: "songs"),
            ]
            
            if let url = components.url {
                do {
                    let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
                    let playlistsResponse = try await dataRequest.response()
                    var songs = [Song]()
                    if let json = try? JSON(data: playlistsResponse.data) {
                        let result = (json["results"]["songs"]["data"]).array ?? []
                        for song in result {
                            let attributes = song["attributes"]
                            let currentSong = Song(id: attributes["playParams"]["id"].string ?? "", name: attributes["name"].string ?? "", artistNamee: attributes["artistName"].string ?? "", artworkURL: attributes["artwork"]["url"].string ?? "", songURL: attributes["previews"][0]["url"].rawValue as? String ?? "")
                            songs.append(currentSong)
                        }
                    }
                    onCompletion(.SUCCESS, songs)
                } catch {
                    print("Error Occured When fetching music from playlist")
                    DispatchQueue.main.async {
                        onCompletion(.FAILED, nil)
                    }
                }
            }
        }
    }
    
    func requestGetAppleArtistResults(searchString: String, onCompletion: @escaping (FetchResults, MusicItemCollection<Album>) -> Void) {
        
        Task {
            do {
                var searchRequest = MusicCatalogSearchRequest(term: searchString, types: [Album.self])
                searchRequest.limit = 25
                let searchResponse = try await searchRequest.response()
                onCompletion(.SUCCESS, searchResponse.albums)
            } catch {
                print("Search request failed with error: \(error).")
                DispatchQueue.main.async {
                    onCompletion(.FAILED, [])
                }
            }
        }
    }
    
//    func requestGetAppleArtistResults(searchString: String, onCompletion: @escaping (FetchResults, MusicItemCollection<Album>) -> Void) {
//        
//        Task {
//            do {
//                var searchRequest = MusicCatalogSearchRequest(term: searchString, types: [Album.self])
//                searchRequest.limit = 25
//                let searchResponse = try await searchRequest.response()
//                onCompletion(.SUCCESS, searchResponse.albums)
//            } catch {
//                print("Search request failed with error: \(error).")
//                DispatchQueue.main.async {
//                    onCompletion(.FAILED, [])
//                }
//            }
//        }
//    }
}
