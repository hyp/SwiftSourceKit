# SwiftSourceKit

Swift bindings for the Swift's source kit daemon.

# Build instructions

Building with swift-lldb:

* Build https://github.com/apple/swift-lldb using the official instructions.
* Clone SwiftSourceKit into swift's root source directory.
* Build SwiftSourceKit using Xcode.

The script 'scripts/copySwiftLibFiles.swift' copies some additional files from swift's build products to SwiftSourceKit build products, without them source kit doesn't work correctly.
