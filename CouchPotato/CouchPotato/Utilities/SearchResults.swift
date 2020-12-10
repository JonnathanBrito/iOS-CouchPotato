//
//  SearchResults.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 11/24/20.
//

import Foundation

class ResultArray: Codable{
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable{
    var StringName: String? = ""
    var OtherString: String? = ""
    //return trackName ?? ""
}
