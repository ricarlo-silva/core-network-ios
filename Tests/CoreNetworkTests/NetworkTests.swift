//
//  NetworkTests.swift
//  CoreNetworkTests
//
//  Created by Ricarlo Silva on 14/11/21.
//

import XCTest
@testable import CoreNetwork

class NetworkTests: XCTestCase {
    
    private lazy var apiClient: NetworkClientProtocol = {
        return NetworkClient.shared
    }()
    
    override func setUp() {
        apiClient.setup(
            authenticator: AuthenticatorInterceptor(sessionLocal: SessionLocal()),
            interceptors: [
                DefaultInterceptor(),
                TokenInterceptor(sessionLocal: SessionLocal())
            ]
        )
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGet() async throws {
        
        let request = Request(
            path: "https://api.github.com/repos/ricarlo-silva/sample-app-ios",
            httpMethod: .GET,
//            queries: [
//                "page": 1,
//                "": "closed",
//                "q": nil
//            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ]
            //            httpBody: User(name: "", email: "")
        )
        
        let result = await apiClient.call(request: request, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPost() async throws {
        
        let request = Request(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
            httpMethod: .POST,
            queries: [
                "page": 1,
                "": "closed",
                "q": nil
            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ],
            httpBody: RepoRequest(
                visibility: "public"
            ).dict
        )
        
        let result = await apiClient.call(request: request, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPut() async throws {
        
        let request = Request(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
            httpMethod: .PUT,
            queries: [
                "page": 1,
                "": "closed",
                "q": nil
            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ],
            httpBody: RepoRequest(
                visibility: "public"
            ).dict
        )
        
        let result = await apiClient.call(request: request, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDelete() async throws {
        
        let request = Request(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
            httpMethod: .DELETE,
            queries: [
                "page": 1,
                "": "closed",
                "q": nil
            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ],
            httpBody: RepoRequest(
                visibility: "public"
            ).dict
        )
        
        let result = await apiClient.call(request: request, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
        case .failure(let error):
            switch error {
            case HttpException.Unauthorized:
                XCTFail(error.localizedDescription)
            case HttpException.ApiError(let error):
                XCTAssertEqual(error.message, "not found")
            default:
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testPatch() async throws {
        
        let request = Request(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
            httpMethod: .PATCH,
            queries: [
                "page": 1,
                "": "closed",
                "q": nil
            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ],
            httpBody: RepoRequest(
                visibility: "public"
            ).dict
        )
        
        let result = await apiClient.call(request: request, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPostUnauthorized() async throws {
        
        let request = Request(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/user",
            httpMethod: .GET
        )
        
        let result = await apiClient.call(request: request, type: OwnerResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.login, "ricarlo-silva")
        case .failure(let error):
            switch error {
            case HttpException.Unauthorized:
                XCTFail(error.localizedDescription)
            case HttpException.ApiError(let error):
                XCTAssertEqual(error.message, "not found")
            default:
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    //    func testDecodingError() async throws {
    //
    //        let request = Request<RepositoryResponse>(
    //            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
    //            httpMethod: .GET
    ////            httpBody: ""
    //        )
    //
    //        let result = await apiClient.call(request: request, type: String.self)
    //
    //        switch result {
    //        case .success:
    //            XCTFail("llk")
    //        case .failure(let error):
    //            XCTAssertTrue(error is DecodingError)
    //        }
    //    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

struct RepoRequest: Codable {
    
    let visibility: String
    
    enum CodingKeys: String, CodingKey {
        case visibility
    }
}

struct RepositoryResponse: Codable {
    
    let id: Int
    let nodeID: String
    let name: String
    let fullName: String
    let owner: OwnerResponse
    let htmlURL: String
    let language: String
    let visibility: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case language
        case visibility
    }
}

// MARK: - Owner
struct OwnerResponse: Codable {
    
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case type
    }
}

class DefaultInterceptor : InterceptorProtocol {
    
    func intercept(request: URLRequest) async -> Result<URLRequest, Error> {
        var _request = request
        _request.setValue("ios", forHTTPHeaderField: "x-os")
        _request.setValue("127.0.0.1", forHTTPHeaderField: "x-ip")
        return .success(_request)
    }
}

class TokenInterceptor : InterceptorProtocol {
    
    private let sessionLocal: SessionLocalProtocol
    
    init(sessionLocal: SessionLocalProtocol) {
        self.sessionLocal = sessionLocal
    }
    
    func intercept(request: URLRequest) async -> Result<URLRequest, Error> {
        var _request = request
        if let token = sessionLocal.getToken() {
            _request.setValue(token, forHTTPHeaderField: "token")
        }
        return .success(_request)
    }
}

class AuthenticatorInterceptor : InterceptorProtocol {
    
    private let sessionLocal: SessionLocalProtocol
    
    init(sessionLocal: SessionLocalProtocol) {
        self.sessionLocal = sessionLocal
    }
    
    func intercept(request: URLRequest) async -> Result<URLRequest, Error> {
        
        // TODO: refresh token
        
        sessionLocal.saveToken(token: "123")
//        var _request = request
//        _request.setValue("456", forHTTPHeaderField: "token")
        return .success(request)
    }
}


protocol SessionLocalProtocol {
    func saveToken(token: String)
    func getToken() -> String?
}

class SessionLocal: SessionLocalProtocol {
    
    private let TOKEN_KEY = "TOKEN_KEY"
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    func saveToken(token: String) {
        defaults.set(token, forKey: TOKEN_KEY)
    }
    
    func getToken() -> String? {
        return defaults.string(forKey: TOKEN_KEY)
    }
}
