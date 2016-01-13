//
//  Request.swift
//  SwiftSourceKit
//

import Foundation
import sourcekitd

public enum RequestValue {
    case UID(sourcekitd_uid_t)
    case Str(String)
    case Integer(Int)
    case Boolean(Bool)
    case Array([RequestValue])
}

extension RequestValue {
    private var sourcekitObject: sourcekitd_object_t {
        switch self {
        case UID(let value): return sourcekitd_request_uid_create(value)
        case Str(let value):
            return value.withCString {
                return sourcekitd_request_string_create($0)
            }
        case Integer(let value): return sourcekitd_request_int64_create(Int64(value))
        case Boolean(let value): return sourcekitd_request_int64_create(value ? 1 : 0)
        case Array(let values):
            let objects = values.map { $0.sourcekitObject }
            let result = objects.withUnsafeBufferPointer {
                return sourcekitd_request_array_create($0.baseAddress, objects.count)
            }
            for i in objects {
                sourcekitd_request_release(i)
            }
            return result
        }
    }
}
    
public final class Request {
    private let request: sourcekitd_object_t
    
    public init(dictionary: [sourcekitd_uid_t : RequestValue], compilerArgs: [String] = []) {
        request = sourcekitd_request_dictionary_create(nil, nil, 0)
        for (key, value) in dictionary {
            let object = value.sourcekitObject
            sourcekitd_request_dictionary_set_value(request, key, object)
            sourcekitd_request_release(object)
        }
        if !compilerArgs.isEmpty {
            let object = RequestValue.Array(compilerArgs.map { RequestValue.Str($0) }).sourcekitObject
            sourcekitd_request_dictionary_set_value(request, KeyCompilerArgs, object)
            sourcekitd_request_release(object)
        }
    }
    
    deinit {
        sourcekitd_request_release(request)
    }
    
    public var description: String {
        guard let str = String.fromCString(sourcekitd_request_description_copy(request)) else {
            return ""
        }
        return str
    }
    
    public func sendAndWaitForResponse() throws -> Response {
        let response = sourcekitd_send_request_sync(request)
        if sourcekitd_response_is_error(response) {
            throw ResponseError(response: response)
        }
        return Response(response: response)
    }

    public func send(errorCallback: (ResponseError) -> (), responseCallback: (Response) -> ()) {
        sourcekitd_send_request(request, nil) {
            (response) in
            if sourcekitd_response_is_error(response) {
                errorCallback(ResponseError(response: response))
            }
            responseCallback(Response(response: response))
        }
    }
}
