//
//  FavMovieRequest.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 12/11/20.
//

import Foundation
import SwiftKeychainWrapper

enum FavMovieError: Error {
    case UrlRequest
    case NoData
    case CantProcess
}


struct FavMovieRequest {
    let API_Key = "5360dbcdd83554f5e5a36e56a57d32c8"
    let SessionToken: String? = KeychainWrapper.standard.string(forKey: "SessionToken")
    
    func getFavMovies(completion: @escaping(Result<[Resultsinfo], FavMovieError>) -> Void) {
        let attempt_url = "https://api.themoviedb.org/3/account/1/favorite/movies?api_key=5360dbcdd83554f5e5a36e56a57d32c8&session_id=\(SessionToken!)&language=en-US&sort_by=created_at.desc&page=1"
//        print(attempt_url)
        //had an error with the URL string from TMDB, had an element not allowed
        guard let url = URL(string: attempt_url)
        else {
            
            fatalError("Invalid URL")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
        guard error == nil else {
            completion(.failure(.UrlRequest))
            return
        }
        
        guard let newData = data else {
            completion(.failure(.NoData))
            return
        }
        do {
            //Data formatter was from StackOverflow with some editing
            //MARK: - Removed as I found it easier to use Strings for querying than dates when it gave me second data too 
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .formatted(formatter)
            let movieDetails = try decoder.decode(FavMovieInfo.self, from: newData)
            let favMoviedata = movieDetails.results
            completion(.success(favMoviedata))
            } catch {
            completion(.failure(.CantProcess))
        }
    }
    task.resume()
    }
}
