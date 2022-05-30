//
//  NetworkClient.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 14/11/21.
//

import Foundation
import TrustKit

private let Content_Type_Form_Urlencoded = "application/x-www-form-urlencoded"
private let Content_Type_Key = "Content-Type"


public protocol NetworkClientProtocol {
    
    func setup(authenticator: AuthenticatorInterceptorProtocol?, interceptors: [InterceptorProtocol])
    func call<T>(request: Request, type: T.Type) async -> Result<T, Error>
    
}

public class NetworkClient : NSObject, NetworkClientProtocol, URLSessionDelegate {
    
    private lazy var config: URLSessionConfiguration = {
        URLSessionConfiguration.ephemeral
    }()
    
    /// URLSession with configured certificate pinning
    private lazy var urlSession: URLSession = {
        URLSession(configuration: config,
                   delegate: self,
                   delegateQueue: nil)//OperationQueue.main)
    }()
    
    
    // MARK: TrustKit Pinning Reference
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        
        guard settings.pinningEnabled else {
            return completionHandler(.performDefaultHandling, nil)
        }
        
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    private let logger: LoggerProtocol
    
    private var authenticator: AuthenticatorInterceptorProtocol? = nil
    
    private var interceptors: [InterceptorProtocol] = []
    
    private let settings: NetworkClientSettings
    
    init(settings: NetworkClientSettings) {
        self.settings = settings
        
        var trustKitConfig: [String: Any] = [:]
        
        if settings.pinningEnabled {
            settings.sslPinning?.forEach { item in
                trustKitConfig[kTSKPinnedDomains] = [
                    item.domain: [
                        kTSKDisableDefaultReportUri: true, /// Disable reporting errors to default domain.
                        kTSKEnforcePinning: true,
                        kTSKIncludeSubdomains: true,
                        kTSKPublicKeyHashes: item.publicKeyHashes ?? [],
                    ]
                ]
            }
        }
        
        self.logger = Logger(logLevel: settings.logLevel)
        
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        super.init()
        
        if let timeout = settings.timeoutIntervalForRequest {
            config.timeoutIntervalForRequest = timeout
        }
        
        if let timeout = settings.timeoutIntervalForResource {
            config.timeoutIntervalForResource = timeout
        }
        
    }
    
    public func setup(
        authenticator: AuthenticatorInterceptorProtocol? = nil,
        interceptors: [InterceptorProtocol] = []
    ) {
        self.authenticator = authenticator
        self.interceptors = interceptors
    }
    
    public func call<T>(
        request: Request,
        type: T.Type
    ) async -> Result<T, Error> {
        
        do {
            let path = try makeURL(path: request.path)
            guard var urlComponents = URLComponents(string: path) else {
                return .failure(HttpException.BadURL)
            }
            
            let queries = request.queries.filter {
                !$0.key.isEmpty && $0.value != nil
            }
            
            if(!queries.isEmpty) {
                urlComponents.queryItems = queries.map {
                    URLQueryItem(name: $0.key, value: "\($0.value ?? "")")
                }
            }
            
            guard let url = urlComponents.url else {
                return .failure(HttpException.BadURL)
            }
            
            var _request = URLRequest(url: url)
            _request.httpMethod = request.httpMethod.rawValue
            
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
            
            if let body = request.httpBody {
                if request.headers.contains(where: { $0.key == Content_Type_Key && "\($0.value ?? "")" == Content_Type_Form_Urlencoded }) {
                    _request.httpBody = body.encode()
                } else {
                    _request.httpBody = body
                }
            }
            
            logger.log(request: _request)
            
            // TODO: iOS version 15 required :(
            // let (data, response) = try await urlSession.data(for: _request)
            
            return await withCheckedContinuation { continuation in
                urlSession.dataTask(with: _request) { [self] (data, response, _) in
                    print("Thread urlSession --> \(Thread.current)")
                    guard let data = data else {
                        continuation.resume(returning: .failure(HttpException.BadURL))
                        return
                    }

                    let httpStatus = response as? HTTPURLResponse
                    let statusCode = httpStatus?.statusCode ?? 0

                    self.logger.log(request: _request, data: data, response: httpStatus)

                    do {
                        switch statusCode {
                        case HttpStatusCode.OK.rawValue ... 299:
                            
                            switch type {
                            case is Decodable.Type:
                                let mappedResponse = try decode(model: T.self, data: data)
                                continuation.resume(returning: .success(mappedResponse!))
                                
                            case is Void.Type:
                                continuation.resume(returning: .success(() as! T))

                            default:
                                // TODO: change error type
                                continuation.resume(returning: .failure(DecodingError.self as! Error))
                            }
                            
                        case HttpStatusCode.UNAUTHORIZED.rawValue, HttpStatusCode.FORBIRDDEN.rawValue:
                            
                            // let result = await authenticator?.intercept(request: _request)
                            
                            guard let authenticator = self.authenticator else {
                                continuation.resume(returning: .failure(HttpException.Unauthorized))
                                return
                            }
                            authenticator.intercept(request: _request) { result in
                                switch result {
                                case .success:
                                    Task {
                                        let result = await self.call(request: request, type: type)
                                        continuation.resume(returning: result)
                                    }
                                default:
                                    continuation.resume(returning: .failure(HttpException.Unauthorized))
                                }
                            }
                        default:
                            let mappedResponse = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
                            continuation.resume(returning: .failure(HttpException.ApiError(mappedResponse, statusCode)))
                        }
                    } catch {
                        continuation.resume(returning: .failure(error))
                    }

                }.resume()
            }
        } catch {
            return .failure(error)
        }
    }
    
    private func makeURL(path: String) throws -> String {
        let baseUrl = settings.baseUrl
        if (path.hasPrefix("http")) {
            return path
        }
        else if (!path.hasPrefix("http") && !baseUrl.isEmpty) {
            if baseUrl.hasSuffix("/") || path.hasPrefix("/") {
                return "\(baseUrl)\(path)"
            }
            return "\(baseUrl)/\(path)"
        }
        else {
            throw HttpException.BadURL
        }
    }

}
