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
        XCTAssertEqual(LogLevel.valueOf("none"), .NONE)
    }
    
    func testExample2() async throws {
        XCTAssertEqual(LogLevel.valueOf("basic"), .BASIC)
    }
    
    func testExample3() async throws {
        XCTAssertEqual(LogLevel.valueOf("headers"), .HEADERS)
    }
    
    func testExample4() async throws {
        XCTAssertEqual(LogLevel.valueOf("body"), .BODY)
    }
    
    func testExample5() async throws {
        XCTAssertEqual(LogLevel.valueOf(nil), .NONE)
    }
}
