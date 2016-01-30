//
//  EditorRequest.swift
//  SwiftSourceKit
//

import sourcekitd

extension Request {
    public static func createEditorOpenRequest(filename: String, sourceText: String, enableSyntaxMap: Bool = true, enableSubStructure: Bool = false, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorOpen),
            KeyName: .Str(filename),
            KeySourceText: .Str(sourceText),
            KeyEnableSyntaxMap: .Boolean(enableSyntaxMap),
            KeyEnableSubStructure: .Boolean(enableSubStructure),
            ], compilerArgs: compilerArgs)
    }

    public static func createEditorCloseRequest(filename: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorClose),
            KeyName: .Str(filename),
            KeySourceText: .Str(""),
        ])
    }

    public static func createEditorReplaceTextRequest(name: String, offset: Int, length: Int, sourceText: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorReplaceText),
            KeyName: .Str(name),
            KeyOffset: .Integer(offset),
            KeyLength: .Integer(length),
            KeySourceText: .Str(sourceText),
        ])
    }

    public static func createCursorInfoRequestForFile(filename: String, offset: Int, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestCursorInfo),
            KeySourceFile: .Str(filename),
            KeyOffset: .Integer(offset)
        ], compilerArgs: compilerArgs)
    }
}
