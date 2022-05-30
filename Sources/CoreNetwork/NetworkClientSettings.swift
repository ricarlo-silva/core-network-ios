//
//  NetworkClientSettings.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/03/22.
//

public struct NetworkClientSettings: Codable {
    
    let baseUrl: String
    let timeoutIntervalForRequest: Double?
    let timeoutIntervalForResource: Double?
    let logLevel: LogLevel
    let pinningEnabled: Bool
    let sslPinning: Array<SslPinningSettings>?
    
    init(
        baseUrl: String = "",
        timeoutIntervalForRequest: Double? = nil,
        timeoutIntervalForResource: Double? = nil,
        logLevel: LogLevel = .NONE,
        pinningEnabled: Bool = false,
        sslPinning: Array<SslPinningSettings>? = nil
    ) {
        self.baseUrl = baseUrl
        self.timeoutIntervalForRequest = timeoutIntervalForRequest
        self.timeoutIntervalForResource = timeoutIntervalForResource
        self.logLevel = logLevel
        self.pinningEnabled = pinningEnabled
        self.sslPinning = sslPinning
    }
    
    enum CodingKeys: String, CodingKey {
        case baseUrl
        case timeoutIntervalForRequest
        case timeoutIntervalForResource
        case logLevel
        case pinningEnabled
        case sslPinning
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
