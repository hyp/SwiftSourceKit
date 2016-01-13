//
//  EditorRequest.swift
//  SwiftSourceKit
//

import sourcekitd

extension Request {
    static func createEditorOpenRequest(filename: String, sourceText: String, enableSyntaxMap: Bool = true, enableSubStructure: Bool = false, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorOpen),
            KeyName: .Str(filename),
            KeySourceText: .Str(sourceText),
            KeyEnableSyntaxMap: .Boolean(enableSyntaxMap),
            KeyEnableSubStructure: .Boolean(enableSubStructure),
            ], compilerArgs: compilerArgs)
    }

    static func createEditorCloseRequest(filename: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorClose),
            KeyName: .Str(filename),
            KeySourceText: .Str(""),
        ])
    }
}
