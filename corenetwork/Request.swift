//
//  Request.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/11/21.
//

import Foundation

public struct Request {
    
    public let path: String
    public let httpMethod: HttpMethod
    public let httpBody: Data?
    public let queries: [String: Any?]
    public let headers: [String: Any?]
    
    public init(
        path: String,
        httpMethod: HttpMethod,
        queries: [String: Any?] = [:],
        headers: [String: Any?] = [:],
        httpBody: Data? = nil
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queries = queries
        self.headers = headers
        self.httpBody = httpBody
    }
}
