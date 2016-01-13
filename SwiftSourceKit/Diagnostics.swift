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
    public let kind: Kind
    public let stage: StageKind
    public let line: Int
    public let column: Int
    public let filepath: String
    public let description: String

    public init(kind: Kind, stage: StageKind, line: Int, column: Int, filepath: String, description: String) {
        self.kind = kind
        self.stage = stage
        self.line = line
        self.column = column
        self.filepath = filepath
        self.description = description
    }
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
        let variant = Variant(variant: value)
        let filepath = variant[StringForKey: KeyFilePath]
        let line = Int(sourcekitd_variant_dictionary_get_int64(value, KeyLine))
        let column = Int(sourcekitd_variant_dictionary_get_int64(value, KeyColumn))
        let severity = sourcekitd_variant_dictionary_get_uid(value, KeySeverity)
        let stage = sourcekitd_variant_dictionary_get_uid(value, KeyDiagnosticStage)
        let description = variant[StringForKey: KeyDescription]
        return Diagnostic(kind: getDiagnosticKind(severity), stage: getDiagnosticStageKind(stage), line: line, column: column, filepath: filepath, description: description)
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
