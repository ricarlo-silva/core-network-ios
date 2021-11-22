//
//  networkTests.swift
//  networkTests
//
//  Created by Ricarlo Silva on 14/11/21.
//

import XCTest
@testable import CoreNetwork

class NetworkTests: XCTestCase {
    
    private let apiClient = NetworkClient.shared
    
    override func setUp() {
        apiClient.setup(defaultHeaders: [
            "x-ip": "127.0.0.1"
        ])
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGet() async throws {
        
        let requet = Request<RepositoryResponse>(
            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
            httpMethod: .GET,
            queries: [
                "page": 1,
                "": "closed",
                "q": nil
            ],
            headers: [
                "accept": "application/vnd.github.v3+json",
                "": "test",
                "q": nil
            ]
//            httpBody: User(name: "", email: "")
        )
        
        let result = await apiClient.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPost() async throws {
        
        let requet = Request<RepoRequest>(
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
            )
        )
        
        let result = await apiClient.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPut() async throws {
        
        let requet = Request<RepoRequest>(
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
            )
        )
        
        let result = await apiClient.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDelete() async throws {
        
        let requet = Request<RepoRequest>(
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
            )
        )
        
        let result = await apiClient.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
        case .failure(let error):
            switch error {
            case ApiErrorException.Unauthorized:
                XCTFail(error.localizedDescription)
            case ApiErrorException.ApiError(let error):
                XCTAssertEqual(error.message, "not found")
            default:
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testPatch() async throws {
        
        let requet = Request<RepoRequest>(
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
            )
        )
        
        let result = await apiClient.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
//    func testDecodingError() async throws {
//
//        let requet = Request<RepositoryResponse>(
//            path: "https://05cf207c-4c73-4096-8de1-8d880bb934e7.mock.pstmn.io/news",
//            httpMethod: .GET
////            httpBody: ""
//        )
//
//        let result = await apiClient.getRequest(request: requet, type: String.self)
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
