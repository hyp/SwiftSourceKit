//
//  EditorRequest.swift
//  SwiftSourceKit
//

import sourcekitd

extension Request {
    public static func createEditorOpenRequest(_ filename: String, sourceText: String, enableSyntaxMap: Bool = true, enableSubStructure: Bool = false, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .uid(RequestEditorOpen),
            KeyName: .str(filename),
            KeySourceText: .str(sourceText),
            KeyEnableSyntaxMap: .boolean(enableSyntaxMap),
            KeyEnableSubStructure: .boolean(enableSubStructure),
            ], compilerArgs: compilerArgs)
    }

    public static func createEditorCloseRequest(_ filename: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .uid(RequestEditorClose),
            KeyName: .str(filename),
            KeySourceText: .str(""),
        ])
    }

    public static func createEditorReplaceTextRequest(_ name: String, offset: Int, length: Int, sourceText: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .uid(RequestEditorReplaceText),
            KeyName: .str(name),
            KeyOffset: .integer(offset),
            KeyLength: .integer(length),
            KeySourceText: .str(sourceText),
        ])
    }

    public static func createCursorInfoRequestForFile(_ filename: String, offset: Int, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .uid(RequestCursorInfo),
            KeySourceFile: .str(filename),
            KeyOffset: .integer(offset)
        ], compilerArgs: compilerArgs)
    }
}
