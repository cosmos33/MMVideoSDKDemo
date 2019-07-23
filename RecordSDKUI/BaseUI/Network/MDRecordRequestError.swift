//
//  RequestError.swift
//  ImageAdviser
//
//  Created by sunfei on 07/02/2018.
//  Copyright © 2018 DEMO. All rights reserved.
//

import Foundation

enum MDRecordRequestError: Error {
  
  enum ParameterEncodingFailureReason {
    case missingURL
    case jsonEncodingFailed(error: Error)
    case propertyListEncodingFailed(error: Error)
  }
  
  enum ResponseValidationFailureReason {
    case dataFileNil
    case unacceptableStatusCode(code: Int)
  }
  
  enum ResponseSerializationFailureReason {
    case jsonSerializationFailed
  }
  
  case invalidURL(url: URL)
  case methodRestriction(supportedMethod: String)
  case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
  case responseValidationFailed(reason: ResponseValidationFailureReason)
  case responseSerializationFailed(reson: ResponseSerializationFailureReason)
  case cancel
}

extension MDRecordRequestError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidURL(let url):
      return "invalid url: \(url)"
    case .methodRestriction(let supportedMethod):
      return supportedMethod
    case .parameterEncodingFailed(let reason):
      return reason.localizedDescription
    case .responseValidationFailed(let reason):
      return reason.localizedDescription
    case .responseSerializationFailed(let reason):
      return reason.localizedDescription
    case .cancel:
      return "request is cancelled"
    }
  }
}

extension MDRecordRequestError.ParameterEncodingFailureReason {
  var localizedDescription: String {
    switch self {
    case .missingURL:
      return "URL request to encode was missing a URL"
    case .jsonEncodingFailed(let error):
      return "JSON could not be encoded because of error:\n\(error.localizedDescription)"
    case .propertyListEncodingFailed(let error):
      return "PropertyList could not be encoded because of error:\n\(error.localizedDescription)"
    }
  }
}

extension MDRecordRequestError.ResponseSerializationFailureReason {
  var localizedDescription: String {
    switch self {
    case .jsonSerializationFailed:
      return "JSON could not be encoded"
    }
  }
}

extension MDRecordRequestError.ResponseValidationFailureReason {
  var localizedDescription: String {
    switch self {
    case .dataFileNil:
      return "response data file is nil"
    case .unacceptableStatusCode(let code):
      return "Response status code is unacceptable: \(code)."
    }
  }
}

extension MDRecordRequestError {
  var isInvalidURLError: Bool {
    if case .invalidURL = self {
      return true
    }
    return false
  }
  
  var isMethodRestrictionError: Bool {
    if case .methodRestriction = self {
      return true
    }
    return false
  }
  
  var isParameterEncodingFailedError: Bool {
    if case .parameterEncodingFailed = self {
      return true
    }
    return false
  }
  
  var isResponseValidationFailedError: Bool {
    if case .responseValidationFailed = self {
      return true
    }
    return false
  }
  
  var isResponseSerializationFailedError: Bool {
    if case .responseSerializationFailed = self {
      return true
    }
    return false
  }
  
  var isCancelError: Bool {
    if case .cancel = self {
      return true
    }
    return false
  }
}
