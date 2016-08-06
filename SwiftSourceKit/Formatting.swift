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
    public static func createEditorFormatRequestForLine(_ line: Int, name: String, length: Int, options: FormattingOptions) -> Request {
        return Request(dictionary: [
            KeyRequest: .uid(RequestEditorFormatText),
            KeyName: .str(name),
            KeyLine: .integer(line),
            KeyLength: .integer(length),
            KeySourceText: .str(""),
            KeyFormatOptions: .dictionary([
                KeyFormatIndentWidth: .integer(options.indentWidth),
                KeyFormatTabWidth: .integer(options.tabWidth),
                KeyFormatUseTabs: .boolean(options.useTabs)
            ])
        ])
    }
}
