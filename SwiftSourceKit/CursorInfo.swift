//
//  CursorInfo.swift
//  SwiftSourceKit
//

import sourcekitd

public struct CursorInfo {
    public typealias KindUID = sourcekitd_uid_t
    public let kind: KindUID
    public let name: String
    public let usr: String
    public let filepath: String
    public let offset: Int?
    public let length: Int?
    public let typename: String
    public let isSystem: Bool
    public let modulename: String

    public init?(variant: Variant) {
        guard case Variant.VariantType.Dictionary = variant.type else { return nil }
        kind = variant[UIDForKey: KeyKind]
        guard kind != nil else { return nil }
        name = variant[StringForKey: KeyName]
        usr = variant[StringForKey: KeyUSR]
        typename = variant[StringForKey: KeyTypename]
        filepath = variant[StringForKey: KeyFilePath]
        let len = variant[IntForKey: KeyLength]
        if len != 0 {
            offset = variant[IntForKey: KeyOffset]
            length = len
        } else {
            offset = nil
            length = nil
        }
        isSystem = variant[BoolForKey: KeyIsSystem]
        modulename = variant[StringForKey: KeyModuleName]
    }
}
