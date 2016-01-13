//
//  EditorRequest.swift
//  SwiftSourceKit
//

import sourcekitd

public final class EditorOpenRequest: Request {
    public init(filename: String, sourceText: String, enableSyntaxMap: Bool = true, enableSubStructure: Bool = false, compilerArgs: [String] = []) {
        super.init(dictionary: [
            KeyRequest: .UID(RequestEditorOpen),
            KeyName: .Str(filename),
            KeySourceText: .Str(sourceText),
            KeyEnableSyntaxMap: .Boolean(enableSyntaxMap),
            KeyEnableSubStructure: .Boolean(enableSubStructure),
        ], compilerArgs: compilerArgs)
    }
}

extension Request {
    static func createEditorCloseRequest(filename: String) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorClose),
            KeyName: .Str(filename),
            KeySourceText: .Str(""),
        ])
    }
}
