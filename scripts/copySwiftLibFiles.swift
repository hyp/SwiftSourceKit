#!/usr/bin/env xcrun swift
// Copy the required files to build products directory.

import Foundation

if CommandLine.arguments.count < 3 {
    fatalError("No arguments given")
}

let dict = ProcessInfo.processInfo.environment
let srcRoot = CommandLine.arguments[1]
let builtProductsDir = CommandLine.arguments[2]

var moduleFiles = ["libswiftCore.dylib", "libswiftSwiftPrivate.dylib", "libswiftSwiftPrivateLibcExtras.dylib", "libswiftSwiftPrivatePthreadExtras.dylib", "Swift.swiftdoc", "Swift.swiftmodule", "SwiftPrivate.swiftdoc", "SwiftPrivate.swiftmodule", "SwiftPrivateLibcExtras.swiftdoc", "SwiftPrivateLibcExtras.swiftmodule", "SwiftPrivatePthreadExtras.swiftdoc", "SwiftPrivatePthreadExtras.swiftmodule", "SwiftOnoneSupport.swiftdoc", "SwiftOnoneSupport.swiftmodule", "libswiftSwiftOnoneSupport.dylib"]
let paths = [(from: "swift/shims", to: "swift"), (from: "swift/clang", to: "swift")]

// Parse additional parameters
var i = 3
while i < CommandLine.arguments.count {
    switch CommandLine.arguments[i] {
    case "-file":
        i += 1
        if i >= CommandLine.arguments.count {
            fatalError("Expected an argument after '-file'")
        }
        moduleFiles.append(CommandLine.arguments[i])
    case let arg:
        fatalError("Unknown argument '\(arg)'")
    }
    i += 1
}

let files = moduleFiles.map { "swift/macosx/x86_64/" + $0 }

func copy(from: String, to: String) {
    let task = Process()
    task.launchPath = "/bin/cp"
    task.arguments = ["-r", from, to]
    task.launch()
    task.waitUntilExit()
    if task.terminationStatus != 0 {
        fatalError("Failed to copy from '\(from)' to '\(to)'")
    }
}

func mkdir(_ path: String) {
    let task = Process()
    task.launchPath = "/bin/mkdir"
    task.arguments = ["-p", path]
    task.launch()
    task.waitUntilExit()
    if task.terminationStatus != 0 {
        fatalError("Failed to mkdir '\(path)'")
    }
}

let dirs = ["swift", "swift/macosx/x86_64"]
for dir in dirs {
    mkdir(URL(fileURLWithPath: builtProductsDir).appendingPathComponent(dir).path)
}

let frameworkPath: String
switch dict["CONFIGURATION"]!.lowercased() {
case "debug":
	frameworkPath = "/build/Ninja-DebugAssert/swift-macosx-x86_64/lib"
case "release":
	frameworkPath = "/build/Ninja-ReleaseAssert/swift-macosx-x86_64/lib"
default:
    fatalError("Unsupported build configuration")
}

func from(_ path: String) -> String {
	return URL(fileURLWithPath: srcRoot).appendingPathComponent(frameworkPath).appendingPathComponent(path).path
}
print("Copying debug files")
for path in files {
    copy(from: from(path), to: URL(fileURLWithPath: builtProductsDir).appendingPathComponent(path).path)
}
for path in paths {
    copy(from: from(path.from), to: URL(fileURLWithPath: builtProductsDir).appendingPathComponent(path.to).path)
}
