//
//  Diagnostics.swift
//  SwiftSourceKit
//

import sourcekitd

// Represents a diagnostic.
public struct Diagnostic {
    public enum Kind {
        case Error
        case Warning
        case Note
        case Other
    }
    public enum StageKind {
        case Parse
        case Sema
        case Other
    }
    private let variant: Variant

    private init(value: sourcekitd_variant_t) {
        variant = Variant(dictionary: value)
    }

    public var kind: Kind {
        return getDiagnosticKind(variant[UIDForKey: KeySeverity])
    }
    public var stage: StageKind {
        return getDiagnosticStageKind(variant[UIDForKey: KeyDiagnosticStage])
    }
    public var line: Int {
        return variant[IntForKey: KeyLine]
    }
    public var column: Int {
        return variant[IntForKey: KeyColumn]
    }
    public var filePath: String {
        return variant[StringForKey: KeyFilePath]
    }
    public var description: String {
        return variant[StringForKey: KeyDescription]
    }
    public var diagnostics: Diagnostics? {
        let diagsArray = sourcekitd_variant_dictionary_get_value(variant.variant, KeyDiagnostics)
        return sourcekitd_variant_get_type(diagsArray) != SOURCEKITD_VARIANT_TYPE_ARRAY ? nil :
            try? Diagnostics(variant: Variant(variant: diagsArray))
    }
    public var fixits: [DiagnosticFixit] {
        let fixitsArray = sourcekitd_variant_dictionary_get_value(variant.variant, KeyFixits)
        let fixits = sourcekitd_variant_get_type(fixitsArray) != SOURCEKITD_VARIANT_TYPE_ARRAY ? [] :
            (0..<sourcekitd_variant_array_get_count(fixitsArray)).map {
                (i) -> DiagnosticFixit in
                let value = sourcekitd_variant_array_get_value(fixitsArray, i)
                return DiagnosticFixit(offset: Int(sourcekitd_variant_dictionary_get_int64(value, KeyOffset)), length: Int(sourcekitd_variant_dictionary_get_int64(value, KeyLength)), sourceText: Variant(variant: value)[StringForKey: KeySourceText])
        }
        return fixits
    }
}

public struct DiagnosticFixit {
    public let offset: Int
    public let length: Int
    public let sourceText: String
}

public struct DiagnosticGenerator: GeneratorType {
    private let array: sourcekitd_variant_t
    private let count: Int
    private var nextIndex = 0

    init(array: sourcekitd_variant_t) {
        self.array = array
        assert(sourcekitd_variant_get_type(array) == SOURCEKITD_VARIANT_TYPE_ARRAY)
        count = sourcekitd_variant_array_get_count(array)
    }

    mutating public func next() -> Diagnostic? {
        if nextIndex >= count {
            return nil
        }
        let value = sourcekitd_variant_array_get_value(array, nextIndex)
        nextIndex += 1
        assert(sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY)
        return Diagnostic(value: value)
    }
}

public enum DiagnosticsError: ErrorType {
    case InvalidVariant
}

public class Diagnostics: SequenceType {
    private let variant: Variant

    public init(variant: Variant) throws {
        self.variant = variant
        guard case Variant.VariantType.Array = variant.type else { throw DiagnosticsError.InvalidVariant }
    }

    public func generate() -> DiagnosticGenerator {
        return DiagnosticGenerator(array: variant.variant)
    }
}

private func getDiagnosticKind(kind: sourcekitd_uid_t) -> Diagnostic.Kind {
    switch kind {
    case SourceDiagnosticSeverityError: return .Error
    case SourceDiagnosticSeverityWarning: return .Warning
    case SourceDiagnosticSeverityNote: return .Note
    default:
        return .Other
    }
}

private func getDiagnosticStageKind(kind: sourcekitd_uid_t) -> Diagnostic.StageKind {
    switch kind {
    case SourceDiagnosticStageSwiftParse: return .Parse
    case SourceDiagnosticStageSwiftSema: return .Sema
    default:
        return .Other
    }
}
