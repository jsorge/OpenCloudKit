//
//  CKPrettyError.swift
//  OpenCloudKit
//
//  Created by Ben Johnson on 29/07/2016.
//
//

import Foundation

enum CKError {
    case network(NSError)
    case server([String: AnyObject])
    case parse(NSError)
    
    var error: NSError {
        switch  self {
        case .network(let networkError):
            return ckError(forNetworkError: networkError)
        case .server(let dictionary):
            return ckError(forServerResponseDictionary: dictionary)
        case .parse(let parseError):
            return NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: parseError.userInfo)
        }
    }
    
    func ckError(forNetworkError networkError: NSError) -> NSError {
        let userInfo = networkError.userInfo
        let errorCode: CKErrorCode
        
        switch networkError.code {
        case NSURLErrorNotConnectedToInternet:
            errorCode = .NetworkUnavailable
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            errorCode = .ServiceUnavailable
        default:
            errorCode = .NetworkFailure
        }
        
        let error = NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        return error
    }
    
    func ckError(forServerResponseDictionary dictionary: [String: AnyObject]) -> NSError {
        if let recordFetchError = CKRecordFetchErrorDictionary(dictionary: dictionary) {
            
            let errorCode = CKErrorCode.errorCode(serverError: recordFetchError.serverErrorCode)!
            
            var userInfo = [:] as NSErrorUserInfoType
            
            userInfo["redirectURL"] = recordFetchError.redirectURL
            userInfo[NSLocalizedDescriptionKey] = recordFetchError.reason
            
            userInfo[CKErrorRetryAfterKey] = recordFetchError.retryAfter
            userInfo["uuid"] = recordFetchError.uuid
            
            return NSError(domain: CKErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
            
        } else {
            
            let userInfo = [:] as NSErrorUserInfoType
            return NSError(domain: CKErrorDomain, code: CKErrorCode.InternalError.rawValue, userInfo: userInfo)
        }
    }
}
