//
//  NetworkClient.swift
//  corenetwork
//
//  Created by Ricarlo Silva on 14/11/21.
//

import Foundation
import SwiftUI


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

extension Encodable {

    var dict : Data? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
//        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return nil }
        return data
    }
    
}

enum HttpException: Error {
    case BadURL
    case ApiError(_ error: ApiError)
    case Unauthorized
}

struct ApiError: Codable {
    let message: String
}

private let CONFIG_FILE: String = "CoreNetwork"
private let LOG_LEVEL_KEY: String = "LOG_LEVEL"
private let BASE_URL_KEY: String = "BASE_URL"

public class NetworkClient : NSObject {
    
    private var logLevel: Level
//    private var baseUrl: String
    
    //    open class var shared: NetworkClient { get }
    
    public static let shared = NetworkClient()
    
//    private var defaultHeaders: [String: Any?] = [:]
    
    private var authenticator: InterceptorProtocol? = nil
    
    private var interceptors: [InterceptorProtocol] = []

    
    private override init() {
//        // 1
//        guard let filePath = Bundle.main.path(forResource: CONFIG_FILE, ofType: "plist") else {
//            fatalError("Couldn't find file '\(CONFIG_FILE).plist'.")
//        }
//        // 2
//        let plist = NSDictionary(contentsOfFile: filePath)
//        guard let logLevel = plist?.object(forKey: LOG_LEVEL_KEY) as? String else {
//            fatalError("Couldn't find key '\(LOG_LEVEL_KEY)' in '\(CONFIG_FILE).plist'.")
//        }
//
//        self.logLevel = Level.valueOf(logLevel)
//
//        guard let baseUrl = plist?.object(forKey: BASE_URL_KEY) as? String else {
//            fatalError("Couldn't find key '\(BASE_URL_KEY)' in '\(CONFIG_FILE).plist'.")
//        }
//
//        self.baseUrl = baseUrl
        
        self.logLevel = Level.valueOf("body")
        
    }
    
    public func setup(
//        defaultHeaders: [String: Any?] = [:],
        authenticator: InterceptorProtocol? = nil,
        interceptors: [InterceptorProtocol] = []
    ) {
//        self.defaultHeaders = defaultHeaders
        self.authenticator = authenticator
        self.interceptors = interceptors
    }
    
    public func call<T: Codable, R: Codable>(
        request: Request<R>,
        type: T.Type
    ) async -> Result<T, Error> {
        
        do {
            
            guard var urlComponents = URLComponents(string: request.path) else {
                return .failure(HttpException.BadURL)
            }

            urlComponents.queryItems = request.queries.filter {
                !$0.key.isEmpty && $0.value != nil
            }.map {
                URLQueryItem(name: $0.key, value: "\($0.value ?? "")")
            }

            guard let url = urlComponents.url else {
                return .failure(HttpException.BadURL)
            }
            
            var _request = URLRequest(url: url)
            _request.httpMethod = request.httpMethod.rawValue
            
            print("\n\(_request.httpMethod ?? "") \(url.absoluteString)")

//            defaultHeaders.merge(request.headers) { (current, _) in current }

//            defaultHeaders.filter {
//                !$0.key.isEmpty && $0.value != nil
//            }.forEach {
//                _request.setValue("\($0.value ?? "")", forHTTPHeaderField: $0.key)
//            }
            
            request.headers.filter {
                !$0.key.isEmpty && $0.value != nil
            }.forEach {
                _request.setValue("\($0.value ?? "")", forHTTPHeaderField: $0.key)
            }
            
            for interceptor in interceptors {
                let result = await interceptor.intercept(request: _request)
                switch result {
                case .success(let request):
                    _request = request
                case .failure(let error):
                    return .failure(error)
                }
            }
            
            print("Request Headers\n\(_request.allHTTPHeaderFields?.toJSON() ?? "")")

            if let body = request.httpBody {
                _request.httpBody = body.dict
                print("Request Body\n\(_request.httpBody?.toJSON() ?? "")")
            }
            
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            let (data, response) = try await URLSession(configuration: config).data(for: _request)
            
            let httpStatus = response as? HTTPURLResponse
            let statusCode = httpStatus?.statusCode ?? 0

            print("\(statusCode) --> \(_request.httpMethod ?? "") \(url.absoluteString)")
            
            log(data: data, response: httpStatus)
            
            switch statusCode {
            case 200 ... 299:
//                guard data != nil else { return .success(nil) }
                let mappedResponse = try JSONDecoder().decode(T.self, from: data)
                return .success(mappedResponse)
            case 401:
                let result = await authenticator?.intercept(request: _request)
                switch result {
                case .success:
                    return await call(request: request, type: type)
                default:
                    return .failure(HttpException.Unauthorized)
                }
            default:
                let mappedResponse = try JSONDecoder().decode(ApiError.self, from: data)
                return .failure(HttpException.ApiError(mappedResponse))
            }
        } catch {
            
            switch error {
            case is DecodingError:
                print("parse")
            case is HTTPURLResponse:
                print("http")
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
            print("Response Headers\n\(response?.allHeaderFields.toJSON() ?? "")")
            print("Response Body\n\(data.toJSON() ?? "")")
        }
    }
    
}

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
                
//                if(isServerTrusted) {
                //                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                //                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                //                        let data = CFDataGetBytePtr(serverCertificateData);
                //                        let size = CFDataGetLength(serverCertificateData);
                //                        let cert1 = NSData(bytes: data, length: size)
                //                        let file_der = Bundle.main.path(forResource: "certificateFile", ofType: "der")
                //
                //                        if let file = file_der {
                //                            if let cert2 = NSData(contentsOfFile: file) {
                //                                if cert1.isEqual(to: cert2 as Data) {
                //                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                //                                    return
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
                
                if(isServerTrusted) {
                    
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        // Server public key
                        let serverPublicKey = SecCertificateCopyKey(serverCertificate)
                        let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                        let data:Data = serverPublicKeyData as Data
                        // Server Hash key
//                        let serverHashKey = sha256(data: data)
//                        // Local Hash Key
//                        let publickKeyLocal = type(of: self).publicKeyHash
//                        if (serverHashKey == publickKeyLocal) {
//                            completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
//                            return
//                        }
                    }
                }
            }
        }

        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    /**
     Create public key hash
     
     openssl s_client -servername www.github.com -connect www.github.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
     
     https://developer.apple.com/news/?id=g9ejcf8y
     */

}
