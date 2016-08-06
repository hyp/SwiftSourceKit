//
//  ResponseError.swift
//  SwiftSourceKit
//

import sourcekitd

public final class ResponseError: Error {
    private let response: sourcekitd_response_t
    
    init(response: sourcekitd_response_t) {
        self.response = response
    }
    
    deinit {
        sourcekitd_response_dispose(response)
    }
    
    public var description: String {
        guard let str = String(validatingUTF8: sourcekitd_response_error_get_description(response)) else {
            return ""
        }
        return str
    }
    
    public enum ErrorKind {
        case connectionInterrupted
        case requestInvalid
        case requestFailed
        case requestCancelled
        case unknownError
    }
    
    public var errorKind: ErrorKind {
        let kind = sourcekitd_response_error_get_kind(response)
        switch kind {
        case SOURCEKITD_ERROR_CONNECTION_INTERRUPTED: return .connectionInterrupted
        case SOURCEKITD_ERROR_REQUEST_INVALID: return .requestInvalid
        case SOURCEKITD_ERROR_REQUEST_FAILED: return .requestFailed
        case SOURCEKITD_ERROR_REQUEST_CANCELLED: return .requestCancelled
        default:
            return .unknownError
        }
    }
}
