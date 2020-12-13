

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
