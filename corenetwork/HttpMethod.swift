//
//  MethodType.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 20/11/21.
//

import Foundation

public enum HttpMethod: String {
    
    /**
     Used for retrieving resources.
     */
    case GET = "GET"
    
    /**
     Used for creating resources.
     */
    case POST = "POST"
    
    /**
     Used for updating resources with partial JSON data. For instance, an Issue resource has title and body attributes.
     A PATCH request may accept one or more of the attributes to update the resource.
     */
    case PATCH = "PATCH"
    
    /**
     Used for replacing resources or collections. For PUT requests with no body attribute, be sure to set the Content-Length header to zero.
     */
    case PUT = "PUT"
    
    /**
     Used for deleting resources.
     */
    case DELETE = "DELETE"
}
