//
//  Request.swift
//  SwiftSourceKit
//

import sourcekitd

public enum RequestValue {
    case uid(sourcekitd_uid_t)
    case str(String)
    case integer(Int)
    case boolean(Bool)
    case array([RequestValue])
    case dictionary([sourcekitd_uid_t : RequestValue])
}

extension RequestValue {
    private var sourcekitObject: sourcekitd_object_t {
        switch self {
        case .uid(let value): return sourcekitd_request_uid_create(value)
        case .str(let value):
            return value.withCString {
                return sourcekitd_request_string_create($0)
            }
        case .integer(let value): return sourcekitd_request_int64_create(Int64(value))
        case .boolean(let value): return sourcekitd_request_int64_create(value ? 1 : 0)
        case .array(let values):
            let objects = values.map { Optional($0.sourcekitObject) }
            let result = objects.withUnsafeBufferPointer {
                return sourcekitd_request_array_create($0.baseAddress, objects.count)
            }
            for i in objects {
                sourcekitd_request_release(i!)
            }
            return result!
        case .dictionary(let dictionary):
            let result = sourcekitd_request_dictionary_create(nil, nil, 0)
            for (key, value) in dictionary {
                let object = value.sourcekitObject
                sourcekitd_request_dictionary_set_value(result!, key, object)
                sourcekitd_request_release(object)
            }
            return result!
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
            let object = RequestValue.array(compilerArgs.map { RequestValue.str($0) }).sourcekitObject
            sourcekitd_request_dictionary_set_value(request, KeyCompilerArgs, object)
            sourcekitd_request_release(object)
        }
    }
    
    deinit {
        sourcekitd_request_release(request)
    }
    
    public var description: String {
        guard let str = String(validatingUTF8: sourcekitd_request_description_copy(request)) else {
            return ""
        }
        return str
    }
    
    public func sendAndWaitForResponse() throws -> Response {
        guard let response = sourcekitd_send_request_sync(request) else {
            fatalError("No response received")
        }
        if sourcekitd_response_is_error(response) {
            throw ResponseError(response: response)
        }
        return Response(response: response)
    }

    public func send(_ errorCallback: (ResponseError) -> (), responseCallback: (Response) -> ()) {
        sourcekitd_send_request(request, nil) {
            (response) in
            if sourcekitd_response_is_error(response!) {
                errorCallback(ResponseError(response: response!))
            } else {
                responseCallback(Response(response: response!))
            }
        }
    }
}
