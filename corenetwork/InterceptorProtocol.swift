//
//  InterceptorProtocol.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 22/11/21.
//

import Foundation

public protocol InterceptorProtocol {
    
    func intercept(request: URLRequest) async -> Result<URLRequest, Error>
    
}
