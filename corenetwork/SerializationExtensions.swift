//
//  SerializationExtensions.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 07/12/21.
//

import Foundation

public extension Data {
    
    func toDictionary() -> [String: Any]? {
        if let jsonData = try? JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
            var dictionary: [String: Any] = [:]
            for key in jsonData.allKeys {
                let stringKey = key as? String
                if let key = stringKey, let keyValue = jsonData.value(forKey: key) {
                    dictionary[key] = keyValue
                }
            }
            return dictionary
        }
        return nil
    }
    
    func encode() -> Data? {
        if let dictionary = toDictionary() {
            var urlComponents = URLComponents()
            urlComponents.queryItems = dictionary.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            
            return urlComponents.query?.data(using: .utf8)
        }
        return nil
    }
}

public extension Dictionary {
    
    func toJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
           let jsonText = String(data: jsonData, encoding: String.Encoding.ascii) {
            return jsonText
        }
        return nil
    }
}
