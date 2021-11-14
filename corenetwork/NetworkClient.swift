//
//  NetworkClient.swift
//  corenetwork
//
//  Created by Ricarlo Silva on 14/11/21.
//

import Foundation


extension Data {
    
    func toJSON() -> String? {
        if let jsonData = try? JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary {
            var swiftDict: [String: Any] = [:]
            for key in jsonData.allKeys {
                let stringKey = key as? String
                if let key = stringKey, let keyValue = jsonData.value(forKey: key) {
                    swiftDict[key] = keyValue
                }
            }
           return swiftDict.toJSON()
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

//enum ApiError: Error {
//    case badURL
//}


public class NetworkClient : NSObject {
    var logLevel: Level
//    open class var shared: NetworkClient { get }
    
    public static let shared = NetworkClient()

    private override init() {
//        // 1
//        guard let filePath = Bundle.main.path(forResource: "CoreNetwork", ofType: "plist") else {
//            fatalError("Couldn't find file 'CoreNetwork.plist'.")
//        }
//        // 2
//        let plist = NSDictionary(contentsOfFile: filePath)
//        guard let value = plist?.object(forKey: "LOG_LEVEL") as? String else {
//            fatalError("Couldn't find key 'LOG_LEVEL' in 'CoreNetwork.plist'.")
//        }
        
        logLevel = Level.valueOf("body")
    }
    
    public func getRequest<T: Codable>(
        url: URL,
        type: T.Type
    ) async -> Result<T, Error> {
            
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let httpStatus = response as? HTTPURLResponse
            
            print("\(httpStatus?.statusCode ?? 0) --> \(request.httpMethod ?? "") \(url.absoluteString)")

            log(data: data, response: httpStatus)
            
            let mappedResponse = try JSONDecoder().decode(T.self, from: data)
            return .success(mappedResponse)
        } catch {
            
            switch error {
            case is DecodingError:
                print("parse")
            case is HTTPURLResponse:
                print("http")
    //        case is NSError:
    //            print("http")
            default:
                print("")
            }
      
            return .failure(error)
        }
    }
    
    private func log(data: Data, response: HTTPURLResponse?) {
        switch logLevel {
        case .NONE:
            break
        case .BASIC:
            break
        case .HEADERS:
            break
        case .BODY:
            print("All headers: \(response?.allHeaderFields.toJSON() ?? "")")

            print("Response \(data.toJSON() ?? "")")

        }
    }
    
}

//func ~=<E: Error & Equatable>(rhs: E, lhs: Error) -> Bool {
//    return (lhs as? E) == rhs
//}
