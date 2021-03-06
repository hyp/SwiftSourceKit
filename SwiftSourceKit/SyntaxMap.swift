//
//  SyntaxMap.swift
//  SwiftSourceKit
//

import sourcekitd

// Represents an element of a syntax map.
public struct SyntaxToken {
    public typealias KindUID = sourcekitd_uid_t
    public let kind: KindUID
    public let offset: Int
    public let length: Int
}

public struct SyntaxMapGenerator: IteratorProtocol {
    private let array: sourcekitd_variant_t
    private let count: Int
    private var nextIndex = 0
    
    init(array: sourcekitd_variant_t) {
        self.array = array
        assert(sourcekitd_variant_get_type(array) == SOURCEKITD_VARIANT_TYPE_ARRAY)
        count = sourcekitd_variant_array_get_count(array)
    }
    
    mutating public func next() -> SyntaxToken? {
        if nextIndex >= count {
            return nil
        }
        let value = sourcekitd_variant_array_get_value(array, nextIndex)
        nextIndex += 1
        assert(sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY)
        let kind = sourcekitd_variant_dictionary_get_uid(value, KeyKind)
        let offset = sourcekitd_variant_dictionary_get_int64(value, KeyOffset)
        let length = sourcekitd_variant_dictionary_get_int64(value, KeyLength)
        return SyntaxToken(kind: kind!, offset: Int(offset), length: Int(length))
    }
}

public enum SyntaxMapError: Error {
    case invalidVariant
}

public struct SyntaxMap: Sequence {
    private let variant: Variant
    
    public init(variant: Variant) throws {
        guard case Variant.VariantType.array = variant.type else { throw SyntaxMapError.invalidVariant }
        self.variant = variant
    }
    
    public func makeIterator() -> SyntaxMapGenerator {
        return SyntaxMapGenerator(array: variant.variant)
    }
}
