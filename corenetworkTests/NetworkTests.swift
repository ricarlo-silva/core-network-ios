//
//  networkTests.swift
//  networkTests
//
//  Created by Ricarlo Silva on 14/11/21.
//

import XCTest
@testable import CoreNetwork

class NetworkTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() async throws {
        
        let requet = Request(
            path: "https://api.github.com/repos/ricarlo-silva/sample-app-ios",
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
        
        let result = await NetworkClient.shared.getRequest(request: requet, type: RepositoryResponse.self)
        
        switch result {
        case .success(let repo):
            XCTAssertEqual(repo.name, "sample-app-ios")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodingError() async throws {
        
        let requet = Request(
            path: "https://api.github.com/repos/ricarlo-silva/sample-app-ios",
            httpMethod: .GET
//            httpBody: ""
        )
        
        let result = await NetworkClient.shared.getRequest(request: requet, type: String.self)
        
        switch result {
        case .success:
            XCTFail("llk")
        case .failure(let error):
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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

    enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case language
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
