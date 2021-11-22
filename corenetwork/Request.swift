//
//  Request.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/11/21.
//

import Foundation

public struct Request<T: Codable> {
    
    public let path: String
    public let httpMethod: HttpMethod
    public let httpBody: T?
    public let queries: [String: Any?]
    public let headers: [String: Any?]
    
    public init(
        path: String,
        httpMethod: HttpMethod,
        queries: [String: Any?] = [:],
        headers: [String: Any?] = [:],
        httpBody: T? = nil
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queries = queries
        self.headers = headers
        self.httpBody = httpBody
    }
}
