//
//  SourceKit.swift
//  SwiftSourceKit
//

import sourcekitd

public protocol SourceKitDelegate: class {
    func sourceKitDidReceiveError(_ error: ResponseError)
    func sourceKitDidReceiveNotification(_ response: Response)
}

public final class SourceKit {
    static public var sharedInstance = SourceKit()
    public weak var delegate: SourceKitDelegate?
    
    private init() {
        sourcekitd_initialize()
        sourcekitd_set_notification_handler {
            (response) in
            guard let response = response else {
                assertionFailure()
                return
            }
            if sourcekitd_response_is_error(response) {
                let error = ResponseError(response: response)
                self.delegate?.sourceKitDidReceiveError(error)
                return
            }
            let result = Response(response: response)
            self.delegate?.sourceKitDidReceiveNotification(result)
        }
    }
    
    deinit {
        sourcekitd_shutdown()
    }
}
