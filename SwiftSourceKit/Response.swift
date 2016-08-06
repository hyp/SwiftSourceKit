//
//  Response.swift
//  SwiftSourceKit
//

import sourcekitd

public final class Response {
    private let response: sourcekitd_response_t
    
    init(response: sourcekitd_response_t) {
        self.response = response
    }
    
    deinit {
        sourcekitd_response_dispose(response)
    }
    
    public var description: String {
        guard let str = String(validatingUTF8: sourcekitd_response_description_copy(response)) else {
            return ""
        }
        return str
    }
    
    public var value: Variant {
        return Variant(variant: sourcekitd_response_get_value(response))
    }
}
