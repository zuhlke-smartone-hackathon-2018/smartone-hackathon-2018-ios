//
//  Logger.swift
//
//  Created by Brian Chung on 7/7/2018.
//  Copyright © 2018 Brian Chung. All rights reserved.
//

import Foundation

public enum LogEvent: String {
	case error = "[‼️]" // error
	case info = "[ℹ️]" // info
	case debug = "[💬]" // debug
	case verbose = "[🔬]" // verbose
	case warning = "[⚠️]" // warning	
}

final public class Logger {

	static public func log(
		message: String,
		event: LogEvent,
		fileName: String = #file,
		line: Int = #line,
		column: Int = #column,
		funcName: String = #function) {

		#if DEBUG
		print("\(Date().toString()) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
		#endif
	}

	private static func sourceFileName(filePath: String) -> String {
		let components = filePath.components(separatedBy: "/")
		return components.isEmpty ? "" : components.last!
	}
}

internal extension Date {
	func toString() -> String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.current
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
		return formatter.string(from: self)
	}
}
