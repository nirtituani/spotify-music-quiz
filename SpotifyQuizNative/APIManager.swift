import Foundation

class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://spotify-music-quiz.pages.dev"
    private var accessToken: String?
    
    private init() {}
    
    // MARK: - Authentication
    
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    // MARK: - API Calls
    
    /// Get a random track from the backend
    func getRandomTrack(playlistId: String? = nil, completion: @escaping (Result<Track, Error>) -> Void) {
        var urlString = "\(baseURL)/api/random-track"
        
        if let playlistId = playlistId {
            urlString += "?playlist_id=\(playlistId)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add access token if available
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let track = try JSONDecoder().decode(Track.self, from: data)
                completion(.success(track))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Get user playlists
    func getUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/playlists") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(PlaylistsResponse.self, from: data)
                completion(.success(response.playlists))
            } catch {
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Exchange authorization code for access token
    func getAccessToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/token") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["code": code]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse.accessToken))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Models

struct Track: Codable {
    let id: String
    let name: String
    let artists: String
    let uri: String
    let releaseYear: String?
    let album: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, uri
        case releaseYear = "release_year"
        case album
    }
}

struct Playlist: Codable {
    let id: String
    let name: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case imageUrl = "image_url"
    }
}

struct PlaylistsResponse: Codable {
    let playlists: [Playlist]
}

struct TokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized - please log in"
        }
    }
}
