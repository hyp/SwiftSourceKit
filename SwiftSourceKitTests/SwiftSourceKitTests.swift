//
//  SwiftSourceKitTests.swift
//  SwiftSourceKitTests
//

import XCTest
@testable import SwiftSourceKit

class SwiftSourceKitTests: XCTestCase, SourceKitDelegate {

    override func setUp() {
        super.setUp()
        SourceKit.sharedInstance.delegate = self
    }

    func sourceKitDidReceiveError(error: ResponseError) {
        XCTFail()
    }

    var semaResponseHandler: ((Response) -> ())?

    func sourceKitDidReceiveNotification(response: Response) {
        let value = response.value
        let kind = value[UIDForKey: KeyNotification]
        let name = value[StringForKey: KeyName]
        if kind == NotificationDocumentUpdate {
            print("document update \(name)")
            let request = Request(dictionary: [
                KeyRequest: .UID(RequestEditorReplaceText),
                KeyName: .Str(name),
                KeySourceText: .Str("")
                ])
            do {
                let semaResponse = try request.sendAndWaitForResponse()
                semaResponseHandler?(semaResponse)
            } catch _ {
                XCTFail()
            }
        }
    }

    func testEditorOpen() {
        let request = Request.createEditorOpenRequest("test.swift", sourceText: "let a = 22", enableSyntaxMap: true)
        do {
            let response = try request.sendAndWaitForResponse()
            XCTAssertEqual(response.description, "{\n  key.offset: 0,\n  key.length: 10,\n  key.diagnostic_stage: source.diagnostic.stage.swift.parse,\n  key.syntaxmap: [\n    {\n      key.kind: source.lang.swift.syntaxtype.keyword,\n      key.offset: 0,\n      key.length: 3\n    },\n    {\n      key.kind: source.lang.swift.syntaxtype.identifier,\n      key.offset: 4,\n      key.length: 1\n    },\n    {\n      key.kind: source.lang.swift.syntaxtype.number,\n      key.offset: 8,\n      key.length: 2\n    }\n  ]\n}")
        } catch {
            XCTFail()
        }
        let closeRequest = Request.createEditorCloseRequest("test.swift")
        do {
            try closeRequest.sendAndWaitForResponse()
        } catch {
            XCTFail()
        }
    }

    func testSyntaxMap() {
        let request = Request.createEditorOpenRequest("test.swift", sourceText: "let a = Int(55); let b = \"a\"\n//comment", enableSyntaxMap: true)
        do {
            let response = try request.sendAndWaitForResponse()
            let value = response.value
            print(value.type)
            let syntaxmap = value[VariantForKey: KeySyntaxMap]
            XCTAssertEqual(syntaxmap.type, Variant.VariantType.Array)
            let tokens = Array(try! SyntaxMap(variant: syntaxmap))
            let expectedTokens = [ SyntaxToken(kind: SourceLangSwiftKeyword, offset: 0, length: 3), SyntaxToken(kind: SourceLangSwiftIdentifier, offset: 4, length: 1), SyntaxToken(kind: SourceLangSwiftIdentifier, offset: 8, length: 3), SyntaxToken(kind: SourceLangSwiftNumber, offset: 12, length: 2), SyntaxToken(kind: SourceLangSwiftKeyword, offset: 17, length: 3), SyntaxToken(kind: SourceLangSwiftIdentifier, offset: 21, length: 1), SyntaxToken(kind: SourceLangSwiftString, offset: 25, length: 3), SyntaxToken(kind: SourceLangSwiftComment, offset: 29, length: 9) ]
            XCTAssertEqual(tokens.count, expectedTokens.count)
            for (token, expected) in zip(tokens, expectedTokens) {
                XCTAssertEqual(token.kind, expected.kind)
                XCTAssertEqual(token.offset, expected.offset)
                XCTAssertEqual(token.length, expected.length)
            }
        } catch {
            XCTFail()
        }
    }

    func testResponseError() {
        let request = Request(dictionary: [ KeyRequest: .UID(RequestEditorOpen) ])
        do {
            try request.sendAndWaitForResponse()
            XCTFail()
        } catch let error as ResponseError {
            XCTAssertEqual(error.errorKind, ResponseError.ErrorKind.RequestInvalid)
            XCTAssertEqual(error.description, "missing 'key.name'")
        } catch _ {
            XCTFail()
        }
    }

    func testSemaResponse() {
        var semaResponse: Response?
        semaResponseHandler = {
            (response) in
            semaResponse = response
        }
        defer {
            semaResponseHandler = nil
        }
        let request = Request.createEditorOpenRequest("testSema.swift", sourceText: "let a = 22; a = Int(0)\n let", compilerArgs: ["testSema.swift"])
        do {
            _ = try request.sendAndWaitForResponse()
        } catch _ {
            XCTFail()
        }

        // Instead of using the never returning dispatch_main, we can use the NSRunLoop.
        let loopUntil = NSDate(timeIntervalSinceNow: 10)
        while loopUntil.timeIntervalSinceNow > 0 {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: loopUntil)
        }

        guard let response = semaResponse else {
            XCTFail()
            return
        }
        XCTAssertEqual(response.description, "{\n  key.annotations: [\n    {\n      key.kind: source.lang.swift.ref.var.global,\n      key.offset: 12,\n      key.length: 1\n    },\n    {\n      key.kind: source.lang.swift.ref.struct,\n      key.offset: 16,\n      key.length: 3,\n      key.is_system: 1\n    }\n  ],\n  key.diagnostic_stage: source.diagnostic.stage.swift.sema,\n  key.syntaxmap: [\n  ],\n  key.diagnostics: [\n    {\n      key.line: 2,\n      key.column: 5,\n      key.filepath: \"testSema.swift\",\n      key.severity: source.diagnostic.severity.error,\n      key.description: \"expected pattern\",\n      key.diagnostic_stage: source.diagnostic.stage.swift.parse\n    },\n    {\n      key.line: 1,\n      key.column: 15,\n      key.filepath: \"testSema.swift\",\n      key.severity: source.diagnostic.severity.error,\n      key.description: \"cannot assign to value: \'a\' is a \'let\' constant\",\n      key.diagnostic_stage: source.diagnostic.stage.swift.sema,\n      key.ranges: [\n        {\n          key.offset: 12,\n          key.length: 1\n        }\n      ],\n      key.diagnostics: [\n        {\n          key.line: 1,\n          key.column: 1,\n          key.filepath: \"testSema.swift\",\n          key.severity: source.diagnostic.severity.note,\n          key.description: \"change \'let\' to \'var\' to make it mutable\",\n          key.fixits: [\n            {\n              key.offset: 0,\n              key.length: 3,\n              key.sourcetext: \"var\"\n            }\n          ]\n        }\n      ]\n    }\n  ]\n}")
        let value = response.value
        let diags = value[VariantForKey: KeyDiagnostics]
        XCTAssertEqual(diags.type, Variant.VariantType.Array)
        let diagnostics = Array(try! Diagnostics(variant: diags))
        let expectedDiagnostics = [
            Diagnostic(kind: .Error, stage: .Parse, line: 2, column: 5, filepath: "testSema.swift", description: "expected pattern"),
            Diagnostic(kind: .Error, stage: .Sema, line: 1, column: 15, filepath: "testSema.swift", description: "cannot assign to value: 'a' is a 'let' constant", diagnostics: [ Diagnostic(kind: .Note, stage: .Other, line: 1, column: 1, filepath: "testSema.swift", description: "change 'let' to 'var' to make it mutable", fixits: [ DiagnosticFixit(offset: 0, length: 3, sourceText: "var") ]) ])
        ]
        XCTAssertEqual(diagnostics.count, expectedDiagnostics.count)
        for (diag, expected) in zip(diagnostics, expectedDiagnostics) {
            verifyDiagnostic(diag, expected: expected)
        }
    }

    func testCodeComplete() {
        let sourceText = "Int.\n"
        let request = Request.createEditorOpenRequest("test.swift", sourceText: sourceText, enableSyntaxMap: true)
        do {
            try request.sendAndWaitForResponse()
            let codeCompletionRequest = Request.createCodeCompleteRequest("codeComplete.swift", sourceText: sourceText, offset: 4, compilerArgs: [ "codeComplete.swift" ])
            let response = try codeCompletionRequest.sendAndWaitForResponse()
            let results = Array(try CodeCompletionResults(variant: response.results))
            XCTAssertEqual(results.count, 49)
            let expectedResults = [ (i: 0, CompletionResult(kind: SourceSwiftDeclMethodClass, name: "addWithOverflow(lhs:rhs:)", sourceText: "addWithOverflow(<#T##lhs: Int##Int#>, <#T##rhs: Int##Int#>)", description: "addWithOverflow(lhs: Int, rhs: Int)", typename: "(Int, overflow: Bool)", numBytesToErase: 0)) ]
            for (i, expected) in expectedResults {
                let result = results[i]
                XCTAssertEqual(result.kind, expected.kind)
                XCTAssertEqual(result.name, expected.name)
                XCTAssertEqual(result.sourceText, expected.sourceText)
                XCTAssertEqual(result.description, expected.description)
                XCTAssertEqual(result.typename, expected.typename)
                XCTAssertEqual(result.numBytesToErase, expected.numBytesToErase)
            }
        } catch {
            XCTFail()
        }
    }
}

func verifyDiagnostic(diag: Diagnostic, expected: Diagnostic) {
    XCTAssertEqual(diag.kind, expected.kind)
    XCTAssertEqual(diag.stage, expected.stage)
    XCTAssertEqual(diag.line, expected.line)
    XCTAssertEqual(diag.column, expected.column)
    XCTAssertEqual(diag.filepath, expected.filepath)
    XCTAssertEqual(diag.description, expected.description)
    XCTAssertEqual(diag.diagnostics.count, expected.diagnostics.count)
    for (i, j) in zip(diag.diagnostics, expected.diagnostics) {
        verifyDiagnostic(i, expected: j)
    }
    XCTAssertEqual(diag.fixits.count, expected.fixits.count)
    for (fixit, expected) in zip(diag.fixits, expected.fixits) {
        XCTAssertEqual(fixit.offset, expected.offset)
        XCTAssertEqual(fixit.length, expected.length)
        XCTAssertEqual(fixit.sourceText, expected.sourceText)
    }
}
