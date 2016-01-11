//
//  Response.swift
//  SwiftSourceKit
//

import sourcekitd

class Response {
    private let response: sourcekitd_response_t
    
    init(response: sourcekitd_response_t) {
        self.response = response
    }
    
    deinit {
        sourcekitd_response_dispose(response)
    }
    
    var description: String {
        guard let str = String.fromCString(sourcekitd_response_description_copy(response)) else {
            return ""
        }
        return str
    }
    
    var value: Variant {
        return Variant(variant: sourcekitd_response_get_value(response))
    }
}