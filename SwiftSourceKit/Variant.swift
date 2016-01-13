//
//  Variant.swift
//  SwiftSourceKit
//

import Foundation
import sourcekitd

public struct Variant {
    let variant: sourcekitd_variant_t

    public enum VariantType {
        case Null
        case Dictionary
        case Array
        case Integer
        case Str
        case UID
        case Boolean
    }

    public var type: VariantType {
        switch sourcekitd_variant_get_type(variant) {
        case SOURCEKITD_VARIANT_TYPE_NULL: return .Null
        case SOURCEKITD_VARIANT_TYPE_DICTIONARY: return .Dictionary
        case SOURCEKITD_VARIANT_TYPE_INT64: return .Integer
        case SOURCEKITD_VARIANT_TYPE_ARRAY: return .Array
        case SOURCEKITD_VARIANT_TYPE_STRING: return .Str
        case SOURCEKITD_VARIANT_TYPE_UID: return .UID
        case SOURCEKITD_VARIANT_TYPE_BOOL: return .Boolean
        default:
            fatalError("Invalid sourcekitd variant type")
        }
    }

    init(variant: sourcekitd_variant_t) {
        self.variant = variant
    }

    public subscript(key: sourcekitd_uid_t) -> sourcekitd_uid_t {
        return sourcekitd_variant_dictionary_get_uid(variant, key)
    }

    public subscript(key: sourcekitd_uid_t) -> Int {
        return Int(sourcekitd_variant_dictionary_get_int64(variant, key))
    }

    public subscript(key: sourcekitd_uid_t) -> String {
        guard let str = String.fromCString(sourcekitd_variant_dictionary_get_string(variant, key)) else {
            return ""
        }
        return str
    }
    
    public subscript(key: sourcekitd_uid_t) -> Variant {
        return Variant(variant: sourcekitd_variant_dictionary_get_value(variant, key))
    }
    
    public var description: String {
        guard let str = String.fromCString(sourcekitd_variant_description_copy(variant)) else {
            return ""
        }
        return str
    }
}
