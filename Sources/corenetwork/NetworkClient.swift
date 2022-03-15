//
//  NetworkClient.swift
//  corenetwork
//
//  Created by Ricarlo Silva on 14/11/21.
//

import Foundation
//import TrustKit

private let Content_Type_Form_Urlencoded = "application/x-www-form-urlencoded"
private let Content_Type_Key = "Content-Type"


private let CONFIG_FILE: String = "CoreNetwork"
private let LOG_LEVEL_KEY: String = "LOG_LEVEL"
private let BASE_URL_KEY: String = "BASE_URL"

public protocol NetworkClientProtocol {
    
    func setup(authenticator: InterceptorProtocol?, interceptors: [InterceptorProtocol])
    func call<T: Codable>(request: Request, type: T.Type) async -> Result<T, Error>
    
}

public class NetworkClient : NSObject, NetworkClientProtocol, URLSessionDelegate {
    
    /// URLSession with configured certificate pinning
    lazy var urlSession: URLSession = {
        URLSession(configuration: URLSessionConfiguration.ephemeral,
                   delegate: self,
                   delegateQueue: OperationQueue.main)
    }()

    // TODO: remove domain and public key hardcoded
//    private let trustKitConfig = [
//        kTSKPinnedDomains: [
//            "api.github.com": [
//                kTSKDisableDefaultReportUri: true, /// Disable reporting errors to default domain.
//                kTSKEnforcePinning: true,
//                kTSKIncludeSubdomains: true,
////                    kTSKExpirationDate: "2020-12-20",
//                kTSKPublicKeyHashes: [
//                    "azE5Ew0LGsMgkYqiDpYay0olLAS8cxxNGUZ8OJU756p=",
//                    "azE5Ew0LGsMgkYqiDpYay0olLAS8cxxNGUZ8OJU756k=",
//                ],
//            ]
//        ]
//    ] as [String : Any]


    // MARK: TrustKit Pinning Reference

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?
                           ) -> Void) {

//        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
//        }
    }
    
//    private var baseUrl: String
    
    //    open class var shared: NetworkClient { get }
    
    public static let shared = NetworkClient()
    
    private let logger = Logger.shared
    
    private var authenticator: InterceptorProtocol? = nil
    
    private var interceptors: [InterceptorProtocol] = []

    
    override init() {
//        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        super.init()

        if let filePath = Bundle.main.path(forResource: CONFIG_FILE, ofType: "plist") {
            
            let plist = NSDictionary(contentsOfFile: filePath)
            
            if let logLevel = plist?.object(forKey: LOG_LEVEL_KEY) as? String {
                self.logger.logLevel = Level.valueOf(logLevel)
            }

//            if let baseUrl = plist?.object(forKey: BASE_URL_KEY) as? String {
//                self.baseUrl = baseUrl
//            }
        }
        
    }
    
    public func setup(
        authenticator: InterceptorProtocol? = nil,
        interceptors: [InterceptorProtocol] = []
    ) {
        self.authenticator = authenticator
        self.interceptors = interceptors
    }
    
    public func call<T: Codable>(
        request: Request,
        type: T.Type
    ) async -> Result<T, Error> {
        
        do {
            
            guard var urlComponents = URLComponents(string: request.path) else {
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
            
//            let config = URLSessionConfiguration.ephemeral
//            config.timeoutIntervalForRequest = 30
//            config.timeoutIntervalForResource = 60
            let (data, response) = try await urlSession.data(for: _request) //URLSession(configuration: config, delegate: nil, delegateQueue: .main).data(for: _request)
            
            let httpStatus = response as? HTTPURLResponse
            let statusCode = httpStatus?.statusCode ?? 0

            logger.log(request: _request, data: data, response: httpStatus)
            
            switch statusCode {
            case HttpStatusCode.OK.rawValue ... 299:
                let mappedResponse = try JSONDecoder().decode(T.self, from: data)
                return .success(mappedResponse)
            case HttpStatusCode.UNAUTHORIZED.rawValue, HttpStatusCode.FORBIRDDEN.rawValue:
                let result = await authenticator?.intercept(request: _request)
                switch result {
                case .success:
                    return await call(request: request, type: type)
                default:
                    return .failure(HttpException.Unauthorized)
                }
            default:
                let mappedResponse = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
                return .failure(HttpException.ApiError(mappedResponse))
            }
        } catch {
            return .failure(error)
        }
    }
    
}

//
//    /**
//     Create public key hash
//
//        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

//     openssl s_client -servername api.spotify.com -connect api.spotify.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
//
//     https://developer.apple.com/news/?id=g9ejcf8y
//     */
//
//}
