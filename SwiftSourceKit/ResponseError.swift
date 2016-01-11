//
//  ResponseError.swift
//  SwiftSourceKit
//

import sourcekitd

class ResponseError: ErrorType {
    private let response: sourcekitd_response_t
    
    init(response: sourcekitd_response_t) {
        self.response = response
    }
    
    deinit {
        sourcekitd_response_dispose(response)
    }
    
    var description: String {
        guard let str = String.fromCString(sourcekitd_response_error_get_description(response)) else {
            return ""
        }
        return str
    }
    
    enum ErrorKind {
        case ConnectionInterrupted
        case RequestInvalid
        case RequestFailed
        case RequestCancelled
        case UnknownError
    }
    
    var errorKind: ErrorKind {
        let kind = sourcekitd_response_error_get_kind(response)
        if kind == SOURCEKITD_ERROR_CONNECTION_INTERRUPTED { return .ConnectionInterrupted }
        else if kind == SOURCEKITD_ERROR_REQUEST_INVALID { return .RequestInvalid }
        else if kind == SOURCEKITD_ERROR_REQUEST_FAILED { return .RequestFailed }
        else if kind == SOURCEKITD_ERROR_REQUEST_CANCELLED { return .RequestCancelled }
        return .UnknownError
    }
}