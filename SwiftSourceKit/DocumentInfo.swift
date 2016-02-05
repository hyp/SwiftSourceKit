//
//  DocumentInfo.swift
//  SwiftSourceKit
//

import sourcekitd

extension Request {
    public static func createDocumentInfoRequestForModule(module: String, compilerArgs: [String] = []) -> Request {
        return Request(dictionary: [
            KeyRequest: .UID(RequestDocInfo),
            KeyModuleName: .Str(module),
            ], compilerArgs: compilerArgs)
    }
}

extension Response {
    public var documentEntities: Entities? {
        let value = self.value.variant
        guard sourcekitd_variant_get_type(value) == SOURCEKITD_VARIANT_TYPE_DICTIONARY &&
            sourcekitd_variant_get_type(sourcekitd_variant_dictionary_get_value(value, KeyEntities)) == SOURCEKITD_VARIANT_TYPE_ARRAY else {
            return nil
        }
        return Entities(value: sourcekitd_variant_dictionary_get_value(value, KeyEntities))
    }
}
