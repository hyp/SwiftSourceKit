#!/usr/bin/env xcrun swift
// Copy the required files to build products directory.

import Foundation

let dict = NSProcessInfo.processInfo().environment
let srcRoot = dict["SRCROOT"]!
let builtProductsDir = dict["BUILT_PRODUCTS_DIR"]!

let files = ["libswiftCore.dylib", "libswiftSwiftPrivate.dylib", "libswiftSwiftPrivateDarwinExtras.dylib", "libswiftSwiftPrivatePthreadExtras.dylib", "Swift.swiftdoc", "Swift.swiftmodule", "SwiftPrivate.swiftdoc", "SwiftPrivate.swiftmodule", "SwiftPrivateDarwinExtras.swiftdoc", "SwiftPrivateDarwinExtras.swiftmodule", "SwiftPrivatePthreadExtras.swiftdoc", "SwiftPrivatePthreadExtras.swiftmodule"].map { "swift/macosx/x86_64/" + $0 }
let paths = [(from: "swift/shims", to: "swift")]

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
    mkdir(NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(dir).path!)
}

func from(path: String) -> String {
    return NSURL(fileURLWithPath: srcRoot).URLByAppendingPathComponent("/../build/Ninja-DebugAssert/swift-macosx-x86_64/lib").URLByAppendingPathComponent(path).path!
}

switch dict["CONFIGURATION"]!.lowercaseString {
case "debug":
    print("Copying debug files")
    for path in files {
        copy(from(path), to: NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(path).path!)
    }
    for path in paths {
        copy(from(path.from), to: NSURL(fileURLWithPath: builtProductsDir).URLByAppendingPathComponent(path.to).path!)
    }
    // TODO: Release build configuration
default:
    fatalError("Unsupported build configuration")
}
