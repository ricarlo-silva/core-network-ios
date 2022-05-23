//
//  CodableExtensions.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 07/12/21.
//

import Foundation

public extension Encodable {
    
    var dict : Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Decodable {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

func decode<T>(model: T.Type, data: Data) throws -> T? {
    let decodableType = model as? Decodable.Type
    return try decodableType?.init(data: data) as? T
}


func launch<T>(
    dispatchQueue: DispatchQueue = DispatchQueue.main,
    block: @escaping () async -> (Result<T, Error>),
    completion: @escaping (Result<T, Error>) -> Void
) {

//    return await withCheckedContinuation({ continuation in
        Task {
            let result = await block()
//            dispatchQueue.async {
                completion(result)
//            }
        }
//    })
}
