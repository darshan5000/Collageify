//
//  SpotifyRepository.swift
//  Spotify
//
//  Created by Salvador on 05/02/23.
//

import Foundation

class SpotifyRepository {
    
   static let shared = SpotifyRepository()

    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK: - Http Methods
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
   public func getUserTopTracks(offset: Int = 0, limit: Int = 20) async throws -> [AudioTrack] {
      return try await withCheckedThrowingContinuation { continuation in
         NetworkManager.shared.request(fromURL: URL(string: Constants.userTopTracksUrl + "?offset=\(offset)&limit=\(limit)")!) { (result: Result<UserTopTrackResponse, Error>) in
            switch result {
            case .success(let response):
               continuation.resume(returning: response.items)
            case .failure(let failure):
               continuation.resume(throwing: failure)
            }
         }
      }
   }
    
    // MARK: - Get Recommedations Genre
    public func getRecommedationGenre(completion: @escaping ((Result<RecommendedGenreModel, Error>)) -> Void) {
        createRequest(with: URL(string: Constants.recommendationsGenreUrl), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenreModel.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Recommendations
    public func getRecommendations(genres: Set<String>,completion: @escaping ((Result<RecommendationsModel, Error>)) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.recommendationsUrl + "&seed_genres=\(seeds)"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendationsModel.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Create Requests
    private func createRequest(with url: URL?, type: HTTPMethod,  completion: @escaping (URLRequest) -> Void)  {
        AuthManager.shared.withValidToken { token  in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
   public func search(with query: String) async throws -> [SearchResults] {
      let url = URL(string: Constants.searchUrl + "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!

      return try await withCheckedThrowingContinuation { continuation in
         NetworkManager.shared.request(fromURL: url) { (result: Result<SearchResulsResponse, Error>) in
            switch result {
            case .success(let results):
               var searchResult = [SearchResults]()
               searchResult.append(contentsOf: results.tracks.items.compactMap({ .track(model: $0)}))
               searchResult.append(contentsOf: results.albums.items.compactMap({ .album(model: $0)}))
               searchResult.append(contentsOf: results.artists.items.compactMap({ .artist(model: $0)}))
               searchResult.append(contentsOf: results.playlists.items.compactMap({ .playlist(model: $0)}))

               continuation.resume(returning: searchResult)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
}
