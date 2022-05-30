//
//  LogLevel.swift
//  CoreNetwork
//
//  Created by Ricarlo Silva on 14/11/21.
//

import Foundation

public enum LogLevel: String, CaseIterable, Codable {
    
  /** No logs. */
  case NONE = "NONE"
  
    /**
   * Logs request and response lines.
   *
   * <p>Example:
   * <pre>{@code
   * --> POST /greeting http/1.1 (3-byte body)
   *
   * <-- 200 OK (22ms, 6-byte body)
   * }</pre>
   */
  case BASIC = "BASIC"
  
    /**
   * Logs request and response lines and their respective headers.
   *
   * <p>Example:
   * <pre>{@code
   * --> POST /greeting http/1.1
   * Host: example.com
   * Content-Type: plain/text
   * Content-Length: 3
   * --> END POST
   *
   * <-- 200 OK (22ms)
   * Content-Type: plain/text
   * Content-Length: 6
   * <-- END HTTP
   * }</pre>
   */
  case HEADERS = "HEADERS"
  
    /**
   * Logs request and response lines and their respective headers and bodies (if present).
   *
   * <p>Example:
   * <pre>{@code
   * --> POST /greeting http/1.1
   * Host: example.com
   * Content-Type: plain/text
   * Content-Length: 3
   *
   * Hi?
   * --> END POST
   *
   * <-- 200 OK (22ms)
   * Content-Type: plain/text
   * Content-Length: 6
   *
   * Hello!
   * <-- END HTTP
   * }</pre>
   */
  case BODY = "BODY"
    
    
    var value: String {
         get {
             return self.rawValue
         }
     }
}

extension LogLevel {
    
    static func valueOf(_ value: String?) -> LogLevel {
        guard let value = value else {
            return .NONE
        }
        return LogLevel.allCases.first { $0.value == value.uppercased() } ?? .NONE
    }
}
