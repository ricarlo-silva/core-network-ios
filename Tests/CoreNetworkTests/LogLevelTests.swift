//
//  LogLevelTests.swift
//  CoreNetworkTests
//
//  Created by Ricarlo Silva on 14/11/21.
//

import XCTest
@testable import CoreNetwork

class LogLevelTests: XCTestCase {
    
    func testExample1() async throws {
        XCTAssertEqual(Level.valueOf("none"), .NONE)
    }
    
    func testExample2() async throws {
        XCTAssertEqual(Level.valueOf("basic"), .BASIC)
    }
    
    func testExample3() async throws {
        XCTAssertEqual(Level.valueOf("headers"), .HEADERS)
    }
    
    func testExample4() async throws {
        XCTAssertEqual(Level.valueOf("body"), .BODY)
    }
    
    func testExample5() async throws {
        XCTAssertEqual(Level.valueOf(nil), .NONE)
    }
}
