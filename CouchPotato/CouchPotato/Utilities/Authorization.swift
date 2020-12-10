//
//  Authorization.swift
//  CouchPotato
//
//  Created by Jonnathan Brito on 12/10/20.
//

import Foundation

// MARK: - All Code for Authorization API calls and responses
struct TokenRequest: Codable {
    let success: Bool
    let token: String?
    
    enum tCodingKeys: String, CodingKey {
    case success
    case token = "request_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: tCodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        self.token = try container.decode(String.self, forKey: .token)
        // In case there is a token in a container within your currently defined container
        //let newContainer = try levelAboveContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .[caseNameInLowerContainer]
    }
}

struct SessionData: Codable {
    let success: Bool
    let status_code: Int?
    let status_message: String?
    
    enum sCodingKeys: String, CodingKey {
        case success
        case status_code
        case status_message
    }
}

struct validatedSession: Codable {
    let success: Bool
    let session_id: String?
    
    enum vCodingKeys: String, CodingKey {
        case success
        case session_id
    }
}
