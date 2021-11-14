//
//  networkTests.swift
//  networkTests
//
//  Created by Ricarlo Silva on 14/11/21.
//

import XCTest
@testable import network

class networkTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() async throws {
        
        guard let url = URL(string: "https://www.mockachino.com/736ea5cc-a723-43/users") else {
            return
        }
        let result = await NetworkClient.shared.getRequest(url: url, type: User.self)
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, "test")
            
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDecodingError() async throws {
        
        guard let url = URL(string: "https://www.mockachino.com/736ea5cc-a723-43/users") else {
            return
        }
        let result = await NetworkClient.shared.getRequest(url: url, type: String.self)
        switch result {
        case .success:
            XCTFail("llk")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription == "")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

struct User: Codable {
    let name: String
    let email: String
}
