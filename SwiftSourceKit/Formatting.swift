//
//  Formatting.swift
//  SwiftSourceKit
//

import sourcekitd

public struct FormattingOptions {
    let indentWidth: Int
    let tabWidth: Int
    let useTabs: Bool

    public init(indentWidth: Int, tabWidth: Int, useTabs: Bool) {
        self.indentWidth = indentWidth
        self.tabWidth = tabWidth
        self.useTabs = useTabs
    }
}

extension Request {
    public static func createEditorFormatRequestForLine(line: Int, name: String, length: Int, options: FormattingOptions) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestEditorFormatText),
            KeyName: .Str(name),
            KeyLine: .Integer(line),
            KeyLength: .Integer(length),
            KeySourceText: .Str(""),
            KeyFormatOptions: .Dictionary([
                KeyFormatIndentWidth: .Integer(options.indentWidth),
                KeyFormatTabWidth: .Integer(options.tabWidth),
                KeyFormatUseTabs: .Boolean(options.useTabs)
            ])
        ])
    }
}
