//
//  DocumentEntities.swift
//  SwiftSourceKit
//

import sourcekitd

/// \brief A document entity.
///
/// Its lifetime is tied to the Response object that it came from.
public struct Entity {
    private let variant: Variant
    private init(value: sourcekitd_variant_t) {
        variant = Variant(dictionary: value)
    }

    public var kind: sourcekitd_uid_t {
        return variant[UIDForKey: KeyKind]
    }

    public var name: String {
        return variant[StringForKey: KeyName]
    }

    public var usr: String {
        return variant[StringForKey: KeyUSR]
    }

    public var docAsXML: String {
        return variant[StringForKey: KeyDocFullAsXML]
    }

    public var extends: EntityExtensionInfo? {
        let value = sourcekitd_variant_dictionary_get_value(variant.variant, KeyExtends)
        guard sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY else {
            return nil
        }
        return EntityExtensionInfo(value: value)
    }

    public var entities: Entities? {
        let value = sourcekitd_variant_dictionary_get_value(variant.variant, KeyEntities)
        guard sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_ARRAY else {
            return nil
        }
        return Entities(value: value)
    }

    public var description: String {
        return variant.description
    }

    // Missing properties:
    // generic params(name, inherits)
    // generic requirements.
    // offset.
    // length.
    // conforms.
}

/// \brief Document entity extension info (Used for Swift extension declaration).
///
/// Its lifetime is tied to the Response object that it came from.
public struct EntityExtensionInfo {
    private let variant: Variant
    private init(value: sourcekitd_variant_t) {
        variant = Variant(dictionary: value)
    }

    public var kind: sourcekitd_uid_t {
        return variant[UIDForKey: KeyKind]
    }

    public var name: String {
        return variant[StringForKey: KeyName]
    }

    public var usr: String {
        return variant[StringForKey: KeyUSR]
    }
}

/// \brief A collection of document entities.
///
/// Its lifetime is tied to the Response object that it came from.
public class Entities: SequenceType {
    private let value: sourcekitd_variant_t

    init(value: sourcekitd_variant_t) {
        assert(sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_ARRAY)
        self.value = value
    }

    public func generate() -> EntityGenerator {
        return EntityGenerator(array: value)
    }
}

public struct EntityGenerator: GeneratorType {
    private let array: sourcekitd_variant_t
    private let count: Int
    private var nextIndex = 0

    private init(array: sourcekitd_variant_t) {
        self.array = array
        assert(sourcekitd_variant_get_type(array) == SOURCEKITD_VARIANT_TYPE_ARRAY)
        count = sourcekitd_variant_array_get_count(array)
    }

    mutating public func next() -> Entity? {
        if nextIndex >= count {
            return nil
        }
        let value = sourcekitd_variant_array_get_value(array, nextIndex)
        nextIndex += 1
        assert(sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY)
        return Entity(value: value)
    }
}
