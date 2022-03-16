//
//  Logger.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/12/21.
//

import Foundation

class Logger {
    
    public static let shared = Logger()
    
    var logLevel: Level = .NONE
    
    func log(request: URLRequest) {
        
        guard logLevel != .NONE else {
            return
        }
        
        debug("\n\(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        if(logLevel != .BASIC) {
            debug("Request Headers\n\(request.allHTTPHeaderFields?.toJSON() ?? "")")
        }
        
        if(logLevel == .BODY) {
            debug("Request Body\n\(request.httpBody?.toDictionary()?.toJSON() ?? "")")
        }
    }
    
    func log(request: URLRequest, data: Data, response: HTTPURLResponse?) {
        
        guard logLevel != .NONE else {
            return
        }
        
        let statusCode = response?.statusCode ?? 0
        
        let icon = (HttpStatusCode.OK.rawValue ... 299).contains(statusCode) ? "🟩" : "🟥"
        debug("\(icon) \(statusCode) --> \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        if(logLevel != .BASIC) {
            debug("Response Headers\n\(response?.allHeaderFields.toJSON() ?? "")")
        }
        
        if(logLevel == .BODY) {
            debug("Response Body\n\(data.toDictionary()?.toJSON() ?? "")")
        }
    }
    
    private func debug(_ message: String){
        print(message)
    }
    
}
