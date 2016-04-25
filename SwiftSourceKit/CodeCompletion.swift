//
//  CodeCompletion.swift
//  SwiftSourceKit
//

import sourcekitd

extension Request {
    public static func createCodeCompleteRequest(filename: String, sourceText: String, offset: Int, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestCodeComplete),
            KeyName: .Str(filename),
            KeySourceFile: .Str(filename),
            KeySourceText: .Str(sourceText),
            KeyOffset: .Integer(offset),
            ], compilerArgs: compilerArgs)
    }
}

extension Response {
    public var results: Variant {
        return value[VariantForKey: KeyResults]
    }
}

public struct CompletionResult {
    private let variant: Variant
    public typealias KindUID = sourcekitd_uid_t

    private init(value: sourcekitd_variant_t) {
        variant = Variant(dictionary: value)
    }

    public var kind: KindUID {
        return variant[UIDForKey: KeyKind]
    }
    public var name: String {
        return variant[StringForKey: KeyName]
    }
    public var sourceText: String {
        return variant[StringForKey: KeySourceText]
    }
    public var description: String {
        return variant[StringForKey: KeyDescription]
    }
    public var typename: String {
        return variant[StringForKey: KeyTypename]
    }
    public var numBytesToErase: Int {
        return variant[IntForKey: KeyNumBytesToErase]
    }
    public var moduleName: String {
        return variant[StringForKey: KeyModuleName]
    }
}

public struct CompletionResultGenerator: GeneratorType {
    private let array: sourcekitd_variant_t
    private let count: Int
    private var nextIndex = 0

    init(array: sourcekitd_variant_t) {
        self.array = array
        assert(sourcekitd_variant_get_type(array) == SOURCEKITD_VARIANT_TYPE_ARRAY)
        count = sourcekitd_variant_array_get_count(array)
    }

    mutating public func next() -> CompletionResult? {
        if nextIndex >= count {
            return nil
        }
        let value = sourcekitd_variant_array_get_value(array, nextIndex)
        nextIndex += 1
        assert(sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY)
        return CompletionResult(value: value)
    }
}

public enum CodeCompletionError: ErrorType {
    case InvalidVariant
}

public class CodeCompletionResults: SequenceType {
    private let variant: Variant

    public init(variant: Variant) throws {
        self.variant = variant
        guard case Variant.VariantType.Array = variant.type else { throw CodeCompletionError.InvalidVariant }
    }

    public func generate() -> CompletionResultGenerator {
        return CompletionResultGenerator(array: variant.variant)
    }
}
