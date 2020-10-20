//
//  Logger-Custom.swift
//  LetMeIn
//

import OSLog

extension Logger {
    /// The logger subsystem for this package
    private static let subsystem = (Bundle.main.bundleIdentifier ?? "")
    
    /// Creates a new logger for a category
    /// - Parameter category: The logger category
    /// - Returns: A `Logger` object
    static func `for`(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: "LetMeIn." + category)
    }
}

/// A type that has a shared `OSLog` `Logger`
protocol HasLogger {
    /// A shared `Logger` object for log messages emitted within this class
    static var logger: Logger { get }
    /// The logger to use for log messages emitted within this class
    var logger: Logger { get }
}

extension HasLogger {
    static var logger: Logger { Logger.for(String(describing: self)) }
    var logger: Logger { Self.logger }
}
