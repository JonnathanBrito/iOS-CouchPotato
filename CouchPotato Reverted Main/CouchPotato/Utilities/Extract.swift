//
//  Extract.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/21/20.
//

import Foundation

// MARK: - MovieList
struct MovieList: Codable {
    let page: Int
    let totalResults: Int?
    let totalPages: Int?
    let results: [RESULT]

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}


// MARK: - Result
struct RESULT: Codable {
    let popularity: Double?
    let voteCount: Int?
    let video: Bool?
    let posterPath: String?
    let id: Int?
    let adult: Bool?
    let backdropPath: String?
//    let originalLanguage: OriginalLanguage?
    let originalTitle: String?
    let genreIDS: [Int]?
    let title: String?
    let voteAverage: Double?
    let overview, releaseDate: String?
  
    enum CodingKeys: String, CodingKey {
        case popularity
        case voteCount = "vote_count"
        case video
        case posterPath = "poster_path"
        case id, adult
        case backdropPath = "backdrop_path"
//        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case genreIDS = "genre_ids"
        case title
        case voteAverage = "vote_average"
        case overview
        case releaseDate = "release_date"
    }
}



//class Test {
   
//    func TmdbURL(searchText: String) -> URL {
//        let urlString = String(format: )
//    }
    
    
    
//    func getMovies(){
//
//        //create URL object
//
//        //removes all unuseable characters from searchtext
////        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
////        let urlString = String(format: <#T##String#>, <#T##arguments: CVarArg...##CVarArg#>)
//
//        let url = URL(string: "https://api.themoviedb.org/3/movie/550?api_key=5360dbcdd83554f5e5a36e56a57d32c8")
//
//
//        guard url != nil else {
//            print("Error with URL")
//            return
//        }
//
//        //create URL Session object
//        let session = URLSession.shared
//
//        //get a data task (single call to the api)
//        let dataTask = session.dataTask(with: url!) { (data, response, error) in
//
//            //check for errors
//            if error != nil || data == nil {
//                print("Error with data or there was another error")
//                return
//            }
//            do{
//                let example_movies = JSONDecoder()
////                let result = try example_movies.decode(ResultArray.self, from: data!)
////                return result.results
//            }
////            } catch {
////                print("JSON Error: \(error)")
//            }
            
            //parsing the data
            
//        }
        
        //kick off the task
//        dataTask.resume()
//    }
//}
