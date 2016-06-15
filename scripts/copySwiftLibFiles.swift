#!/usr/bin/env xcrun swift
// Copy the required files to build products directory.

import Foundation

if Process.arguments.count < 3 {
    fatalError("No arguments given")
}

let dict = NSProcessInfo.processInfo().environment
let srcRoot = Process.arguments[1]
let builtProductsDir = Process.arguments[2]

var moduleFiles = ["libswiftCore.dylib", "libswiftSwiftPrivate.dylib", "libswiftSwiftPrivateDarwinExtras.dylib", "libswiftSwiftPrivatePthreadExtras.dylib", "Swift.swiftdoc", "Swift.swiftmodule", "SwiftPrivate.swiftdoc", "SwiftPrivate.swiftmodule", "SwiftPrivateDarwinExtras.swiftdoc", "SwiftPrivateDarwinExtras.swiftmodule", "SwiftPrivatePthreadExtras.swiftdoc", "SwiftPrivatePthreadExtras.swiftmodule"]
let paths = [(from: "swift/shims", to: "swift"), (from: "swift/clang", to: "swift")]

// Parse additional parameters
var i = 3
while i < Process.arguments.count {
    switch Process.arguments[i] {
    case "-file":
        i += 1
        if i >= Process.arguments.count {
            fatalError("Expected an argument after '-file'")
        }
        moduleFiles.append(Process.arguments[i])
    case let arg:
        fatalError("Unknown argument '\(arg)'")
    }
    i += 1
}

let files = moduleFiles.map { "swift/macosx/x86_64/" + $0 }

func copy(from: String, to: String) {
    let task = NSTask()
    task.launchPath = "/bin/cp"
    task.arguments = ["-r", from, to]
    task.launch()
    task.waitUntilExit()
    if task.terminationStatus != 0 {
        fatalError("Failed to copy from '\(from)' to '\(to)'")
    }
}

func mkdir(path: String) {
    let task = NSTask()
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
    mkdir(NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(dir)!.path!)
}

let frameworkPath: String
switch dict["CONFIGURATION"]!.lowercaseString {
case "debug":
	frameworkPath = "/build/Ninja-DebugAssert/swift-macosx-x86_64/lib"
case "release":
	frameworkPath = "/build/Ninja-ReleaseAssert/swift-macosx-x86_64/lib"
default:
    fatalError("Unsupported build configuration")
}

func from(path: String) -> String {
	return NSURL(fileURLWithPath: srcRoot).URLByAppendingPathComponent(frameworkPath)!.URLByAppendingPathComponent(path)!.path!
}
print("Copying debug files")
for path in files {
	copy(from(path), to: NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(path)!.path!)
}
for path in paths {
	copy(from(path.from), to: NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(path.to)!.path!)
}
