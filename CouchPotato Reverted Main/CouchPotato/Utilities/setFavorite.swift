//
//  setFavorite.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 12/11/20.
//

import Foundation

struct SetFavorite: Codable {
    var page: Int
    var results: [Resultsinfo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
    }
}
