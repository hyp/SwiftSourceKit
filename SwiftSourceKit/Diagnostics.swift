//
//  Diagnostics.swift
//  SwiftSourceKit
//

import sourcekitd

// Represents a diagnostic.
public struct Diagnostic {
    public enum Kind {
        case error
        case warning
        case note
        case other
    }
    public enum StageKind {
        case parse
        case sema
        case other
    }
    private let variant: Variant

    fileprivate init(value: sourcekitd_variant_t) {
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

public struct DiagnosticGenerator: IteratorProtocol {
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

public enum DiagnosticsError: Error {
    case invalidVariant
}

public class Diagnostics: Sequence {
    private let variant: Variant

    public init(variant: Variant) throws {
        self.variant = variant
        guard case Variant.VariantType.array = variant.type else { throw DiagnosticsError.invalidVariant }
    }

    public func makeIterator() -> DiagnosticGenerator {
        return DiagnosticGenerator(array: variant.variant)
    }
}

private func getDiagnosticKind(_ kind: sourcekitd_uid_t?) -> Diagnostic.Kind {
    switch kind {
    case SourceDiagnosticSeverityError?: return .error
    case SourceDiagnosticSeverityWarning?: return .warning
    case SourceDiagnosticSeverityNote?: return .note
    default:
        return .other
    }
}

private func getDiagnosticStageKind(_ kind: sourcekitd_uid_t?) -> Diagnostic.StageKind {
    switch kind {
    case SourceDiagnosticStageSwiftParse?: return .parse
    case SourceDiagnosticStageSwiftSema?: return .sema
    default:
        return .other
    }
}
