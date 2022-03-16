//
//  CodableExtensions.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 07/12/21.
//

import Foundation

public extension Encodable {
    
    var dict : Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return data
    }
}
