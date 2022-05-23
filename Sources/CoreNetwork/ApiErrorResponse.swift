//
//  ApiErrorResponse.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 07/12/21.
//

import Foundation

public struct ApiErrorResponse: Codable {
    public let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "mensagem"
    }
}
