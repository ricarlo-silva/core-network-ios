//
//  HttpStatusCode.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 28/12/21.
//

import Foundation

public enum HttpStatusCode: Int {
    case OK = 200
    case BAD_REQUEST = 400
    case UNAUTHORIZED = 401
    case FORBIRDDEN = 403
    case NOT_FOUND = 404
    case PRECONDITION_FAILED = 412
    case INTERNAL_SERVER_ERROR = 500
}
