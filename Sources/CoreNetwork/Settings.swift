//
//  Settings.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/03/22.
//

public struct Settings: Codable {
    let sslPinning: Array<SslPinningSettings>?
    
    enum CodingKeys: String, CodingKey {
        case sslPinning = "SSL_PINNING"
    }
}

public struct SslPinningSettings: Codable {
    let domain: String?
    let publicKeyHashes: Array<String>?
    
    enum CodingKeys: String, CodingKey {
        case domain = "Domain"
        case publicKeyHashes = "PublicKeyHashes"
    }
}
