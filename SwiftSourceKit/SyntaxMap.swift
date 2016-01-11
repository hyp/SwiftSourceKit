//
//  SyntaxMap.swift
//  SwiftSourceKit
//

import sourcekitd

// Represents an element of a syntax map.
public struct SyntaxToken {
    enum Kind {
        case Keyword
        case Identifier
        case Number
        case String
        case Comment
        case Other
    }
    let kind: Kind
    let offset: Int
    let length: Int
}

public struct SyntaxMapGenerator: GeneratorType {
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
        return SyntaxToken(kind: getTokenKind(kind), offset: Int(offset), length: Int(length))
    }
}

enum SyntaxMapError: ErrorType {
    case InvalidVariant
}

struct SyntaxMap: SequenceType {
    private let variant: Variant
    
    init(variant: Variant) throws {
        guard case Variant.VariantType.Array = variant.type else { throw SyntaxMapError.InvalidVariant }
        self.variant = variant
    }
    
    func generate() -> SyntaxMapGenerator {
        return SyntaxMapGenerator(array: variant.variant)
    }
}

private func getTokenKind(kind: sourcekitd_uid_t) -> SyntaxToken.Kind {
    switch kind {
    case SourceLangSwiftKeyword: return .Keyword
    case SourceLangSwiftIdentifier: return .Identifier
    case SourceLangSwiftNumber: return .Number
    case SourceLangSwiftString: return .String
    case SourceLangSwiftComment: return .Comment
    default:
        return .Other
    }
}

