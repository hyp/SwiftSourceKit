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
	public typealias KindUID = sourcekitd_uid_t
	public let kind: KindUID
	public let name: String
	public let sourceText: String
	public let description: String
	public let typename: String
	public let numBytesToErase: Int
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
		let variant = Variant(variant: value)
		return CompletionResult(kind: variant[UIDForKey: KeyKind], name: variant[StringForKey: KeyName], sourceText: variant[StringForKey: KeySourceText], description: variant[StringForKey: KeyDescription], typename: variant[StringForKey: KeyTypename], numBytesToErase: variant[IntForKey: KeyNumBytesToErase])
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
