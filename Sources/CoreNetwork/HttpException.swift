//
//  HttpException.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 07/12/21.
//

import Foundation

public enum HttpException: Error {
    case BadURL
    case ApiError(_ error: ApiErrorResponse,_ statusCode: Int)
    case Unauthorized
}
