//
//  FavoriteMovies.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 12/11/20.
//

import Foundation

struct FavMovieInfo: Codable {
    var page: Int
    var results: [Resultsinfo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
    }
}

struct Resultsinfo: Codable {
    var poster_path: String
    var id: Int
    var vote_average: Double
    var overview: String
    var release_date: String
    var vote_count: Int
//    var genre_id: [Int]
    var title: String
    var original_language: String
    var popularity: Double
    
    enum CodingKeys: String, CodingKey {
//        case genre_id
        case poster_path
        case id
        case title
        case vote_count
        case overview
        case release_date
        case vote_average
        case popularity
        case original_language
        }
    
    //MARK:- From stackoverflow in case genre_id doesn't work, but still gave me problems
    
    init(from decoder: Decoder) throws {
        // First pull out the "products" key
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.poster_path = try container.decode(String.self, forKey: .poster_path)
        self.id = try container.decode(Int.self, forKey: .id)
        self.vote_average = try container.decode(Double.self, forKey: .vote_average)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.release_date = try container.decode(String.self, forKey: .release_date)
        self.vote_count = try container.decode(Int.self, forKey: .vote_count)
//        do {
//            // Then try to decode the value as an array
//            genre_id = try container.decode([Int].self, forKey: .genre_id)
//        } catch {
//            // If that didn't work, try to decode it as a single value
//            genre_id = [try container.decode(Int.self, forKey: .genre_id)]
//        }
        self.title = try container.decode(String.self, forKey: .title)
        self.popularity = try container.decode(Double.self, forKey: .popularity)
        self.original_language = try container.decode(String.self, forKey: .original_language)
    }
    
}

