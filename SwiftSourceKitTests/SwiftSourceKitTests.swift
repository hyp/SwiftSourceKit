//
//  SwiftSourceKitTests.swift
//  SwiftSourceKitTests
//

import XCTest
@testable import SwiftSourceKit

struct TestDiagnostic {
    let kind: Diagnostic.Kind
    let stage: Diagnostic.StageKind
    let line: Int
    let column: Int
    let filePath: String
    let description: String
    let diagnostics: [TestDiagnostic]
    let fixits: [DiagnosticFixit]

    init(kind: Diagnostic.Kind, stage: Diagnostic.StageKind, line: Int, column: Int, filePath: String, description: String, diagnostics: [TestDiagnostic] = [], fixits: [DiagnosticFixit] = []) {
        self.kind = kind
        self.stage = stage
        self.line = line
        self.column = column
        self.filePath = filePath
        self.description = description
        self.diagnostics = diagnostics
        self.fixits = fixits
    }
}

class SwiftSourceKitTests: XCTestCase, SourceKitDelegate {

    override func setUp() {
        super.setUp()
        SourceKit.sharedInstance.delegate = self
    }

    func sourceKitDidReceiveError(_ error: ResponseError) {
        XCTFail()
    }

    var semaResponseHandler: ((Response) -> ())?

    func sourceKitDidReceiveNotification(_ response: Response) {
        let value = response.value
        let kind = value[UIDForKey: KeyNotification]
        let name = value[StringForKey: KeyName]
        if kind == NotificationDocumentUpdate {
            print("document update \(name)")
            let request = Request(dictionary: [
                KeyRequest: .uid(RequestEditorReplaceText),
                KeyName: .str(name),
                KeySourceText: .str("")
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
            XCTAssertEqual(syntaxmap.type, Variant.VariantType.array)
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
        let request = Request(dictionary: [ KeyRequest: .uid(RequestEditorOpen) ])
        do {
            try request.sendAndWaitForResponse()
            XCTFail()
        } catch let error as ResponseError {
            XCTAssertEqual(error.errorKind, ResponseError.ErrorKind.requestInvalid)
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
        let loopUntil = Date(timeIntervalSinceNow: 10)
        while loopUntil.timeIntervalSinceNow > 0 {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: loopUntil)
        }

        guard let response = semaResponse else {
            XCTFail()
            return
        }
        XCTAssertEqual(response.description, "{\n  key.annotations: [\n    {\n      key.kind: source.lang.swift.ref.var.global,\n      key.offset: 12,\n      key.length: 1\n    },\n    {\n      key.kind: source.lang.swift.ref.struct,\n      key.offset: 16,\n      key.length: 3,\n      key.is_system: 1\n    }\n  ],\n  key.diagnostic_stage: source.diagnostic.stage.swift.sema,\n  key.syntaxmap: [\n  ],\n  key.diagnostics: [\n    {\n      key.line: 2,\n      key.column: 5,\n      key.filepath: \"testSema.swift\",\n      key.severity: source.diagnostic.severity.error,\n      key.description: \"expected pattern\",\n      key.diagnostic_stage: source.diagnostic.stage.swift.parse\n    },\n    {\n      key.line: 1,\n      key.column: 15,\n      key.filepath: \"testSema.swift\",\n      key.severity: source.diagnostic.severity.error,\n      key.description: \"cannot assign to value: \'a\' is a \'let\' constant\",\n      key.diagnostic_stage: source.diagnostic.stage.swift.sema,\n      key.ranges: [\n        {\n          key.offset: 12,\n          key.length: 1\n        }\n      ],\n      key.diagnostics: [\n        {\n          key.line: 1,\n          key.column: 1,\n          key.filepath: \"testSema.swift\",\n          key.severity: source.diagnostic.severity.note,\n          key.description: \"change \'let\' to \'var\' to make it mutable\",\n          key.fixits: [\n            {\n              key.offset: 0,\n              key.length: 3,\n              key.sourcetext: \"var\"\n            }\n          ]\n        }\n      ]\n    }\n  ]\n}")
        let value = response.value
        let diags = value[VariantForKey: KeyDiagnostics]
        XCTAssertEqual(diags.type, Variant.VariantType.array)
        let diagnostics = Array(try! Diagnostics(variant: diags))
        let expectedDiagnostics = [
            TestDiagnostic(kind: .error, stage: .parse, line: 2, column: 5, filePath: "testSema.swift", description: "expected pattern"),
            TestDiagnostic(kind: .error, stage: .sema, line: 1, column: 15, filePath: "testSema.swift", description: "cannot assign to value: 'a' is a 'let' constant", diagnostics: [ TestDiagnostic(kind: .note, stage: .other, line: 1, column: 1, filePath: "testSema.swift", description: "change 'let' to 'var' to make it mutable", fixits: [ DiagnosticFixit(offset: 0, length: 3, sourceText: "var") ]) ])
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
            XCTAssertEqual(results.count, 51)
            struct ExpectedCompletion {
                let kind: CompletionResult.KindUID
                let name: String
                let sourceText: String
                let description: String
                let typename: String
                let numBytesToErase: Int
                let moduleName: String
            }
            let expectedResults = [ (i: 0, ExpectedCompletion(kind: SourceSwiftDeclMethodClass, name: "addWithOverflow(::)", sourceText: "addWithOverflow(<#T##lhs: Int##Int#>, <#T##rhs: Int##Int#>)", description: "addWithOverflow(lhs: Int, rhs: Int)", typename: "(Int, overflow: Bool)", numBytesToErase: 0, moduleName: "Swift")) ]
            for (i, expected) in expectedResults {
                let result = results[i]
                XCTAssertEqual(result.kind, expected.kind)
                XCTAssertEqual(result.name, expected.name)
                XCTAssertEqual(result.sourceText, expected.sourceText)
                XCTAssertEqual(result.description, expected.description)
                XCTAssertEqual(result.typename, expected.typename)
                XCTAssertEqual(result.numBytesToErase, expected.numBytesToErase)
                XCTAssertEqual(result.moduleName, expected.moduleName)
            }
        } catch {
            XCTFail()
        }
    }

    func testCursorInfo() {
        let filename = Bundle(for: type(of: self)).path(forResource: "test", ofType: "swift")!

        do {
            let request = Request.createCursorInfoRequestForFile(filename, offset: 9, compilerArgs: [filename])
            do {
                let response = try request.sendAndWaitForResponse()
                guard let info = CursorInfo(variant: response.value) else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(info.kind, SourceSwiftRefStruct)
                XCTAssertEqual(info.name, "Int")
                XCTAssertEqual(info.usr, "s:Si")
                XCTAssertEqual(info.filePath, "")
                XCTAssertEqual(info.offset, nil)
                XCTAssertEqual(info.length, nil)
                XCTAssertEqual(info.typename, "Int.Type")
                XCTAssertEqual(info.isSystem, true)
                XCTAssertEqual(info.modulename, "Swift")
            } catch {
                XCTFail()
            }
        }

        do {
            let request = Request.createCursorInfoRequestForFile(filename, offset: 0, compilerArgs: [filename])
            do {
                let response = try request.sendAndWaitForResponse()
                guard CursorInfo(variant: response.value) == nil else {
                    XCTFail()
                    return
                }
            } catch {
                XCTFail()
            }
        }

        do {
            let request = Request.createCursorInfoRequestForFile(filename, offset: 24, compilerArgs: [filename])
            do {
                let response = try request.sendAndWaitForResponse()
                print(response.description)
                guard let info = CursorInfo(variant: response.value) else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(info.kind, SourceSwiftRefVarGlobal)
                XCTAssertEqual(info.name, "a")
                XCTAssertEqual(info.usr, "s:v4test1aSi")
                XCTAssertEqual(info.filePath, filename)
                XCTAssertEqual(info.offset, 4)
                XCTAssertEqual(info.length, 1)
                XCTAssertEqual(info.typename, "Int")
                XCTAssertEqual(info.isSystem, false)
                XCTAssertEqual(info.modulename, "")
            } catch {
                XCTFail()
            }
        }
    }

    func testDocumentInfo() {
        let request = Request.createDocumentInfoRequestForModule("Swift")
        do {
            let response = try request.sendAndWaitForResponse()
            guard let entities = response.documentEntities else {
                XCTFail()
                return
            }
            for entity in entities {
                if (entity.name == "Bool") {
                    XCTAssert(entity.kind == SourceSwiftDeclStruct)
                    XCTAssert(entity.usr == "s:Sb")
                    XCTAssert(entity.offset > 0)
                    XCTAssert(entity.length > 0)
                    XCTAssertFalse(entity.docAsXML.isEmpty)
                    XCTAssertNil(entity.extends)
                    XCTAssertNotNil(entity.entities)
                    return
                }
            }
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    func testFormatting() {
        struct TestCase {
            let sourceText: String
            let tabs: [String]
            let spaces: [String]
        }
        let testCases = [
            TestCase(sourceText: "class Foo {\n\nvar test : Int\n\tfunc foo(){\n3\n}\n}",
                tabs: ["class Foo {", "\t", "\tvar test : Int", "\tfunc foo(){", "\t\t3", "\t}", "}"],
                spaces: ["class Foo {", "  ", "  var test : Int", "  func foo(){", "    3", "  }", "}"]
            ),
            TestCase(sourceText: "switch 1 {\ncase 0:\nprintln(0)\ncase 1:\nprintln(1)\n}",
                tabs: ["switch 1 {", "case 0:", "\tprintln(0)", "case 1:", "\tprintln(1)", "}"],
                spaces: ["switch 1 {", "case 0:", "  println(0)", "case 1:", "  println(1)", "}"]
            ),
            TestCase(sourceText: "switch 1 {\n\tcase 0:",
                tabs: ["switch 1 {", "case 0:"],
                spaces: ["switch 1 {", "case 0:"]
            ),
            TestCase(sourceText: "for i in 0..<10 {\n",
                tabs: ["for i in 0..<10 {", "\t"],
                spaces: ["for i in 0..<10 {", "  "]
            ),
            TestCase(sourceText: "if true {\nprintln(2)\n\t}",
                tabs: ["if true {", "\tprintln(2)", "}"],
                spaces: ["if true {", "  println(2)", "}"]
            ),
        ]
        for testCase in testCases {
            let request = Request.createEditorOpenRequest("basicFormatTest.swift", sourceText: testCase.sourceText, enableSyntaxMap: true)
            let tabOptions = FormattingOptions(indentWidth: 4, tabWidth: 4, useTabs: true)
            let spaceOptons = FormattingOptions(indentWidth: 2, tabWidth: 2, useTabs: false)
            do {
                try request.sendAndWaitForResponse()
            } catch {
                XCTFail()
            }
            var lineNumber = 1
            testCase.sourceText.enumerateLines { line, stop in
                do {
                    let request = Request.createEditorFormatRequestForLine(lineNumber, name: "basicFormatTest.swift", length: 1, options: tabOptions)
                    let r = try request.sendAndWaitForResponse()
                    let sourceText = r.value[StringForKey: KeySourceText]
                    XCTAssertEqual(sourceText, testCase.tabs[lineNumber - 1])
                } catch {
                    XCTFail()
                }
                do {
                    let request = Request.createEditorFormatRequestForLine(lineNumber, name: "basicFormatTest.swift", length: 1, options: spaceOptons)
                    let r = try request.sendAndWaitForResponse()
                    let sourceText = r.value[StringForKey: KeySourceText]
                    XCTAssertEqual(sourceText, testCase.spaces[lineNumber - 1])
                } catch {
                    XCTFail()
                }
                lineNumber += 1
            }
            let closeRequest = Request.createEditorCloseRequest("basicFormatTest.swift")
            do {
                try closeRequest.sendAndWaitForResponse()
            } catch {
                XCTFail()
            }
        }
    }
}

func verifyDiagnostic(_ diag: Diagnostic, expected: TestDiagnostic) {
    XCTAssertEqual(diag.kind, expected.kind)
    XCTAssertEqual(diag.stage, expected.stage)
    XCTAssertEqual(diag.line, expected.line)
    XCTAssertEqual(diag.column, expected.column)
    XCTAssertEqual(diag.filePath, expected.filePath)
    XCTAssertEqual(diag.description, expected.description)
    if let diags = diag.diagnostics {
        let diagnostics = Array(diags)
        XCTAssertEqual(diagnostics.count, expected.diagnostics.count)
        for (i, j) in zip(diagnostics, expected.diagnostics) {
            verifyDiagnostic(i, expected: j)
        }
    } else {
        XCTAssert(expected.diagnostics.isEmpty)
    }
    XCTAssertEqual(diag.fixits.count, expected.fixits.count)
    for (fixit, expected) in zip(diag.fixits, expected.fixits) {
        XCTAssertEqual(fixit.offset, expected.offset)
        XCTAssertEqual(fixit.length, expected.length)
        XCTAssertEqual(fixit.sourceText, expected.sourceText)
    }
}
