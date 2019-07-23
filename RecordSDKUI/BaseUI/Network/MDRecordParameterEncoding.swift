//
//  ParameterEncoding.swift
//  ImageAdviser
//
//  Created by sunfei on 07/02/2018.
//  Copyright © 2018 DEMO. All rights reserved.
//

import Foundation

protocol MDRecordParameterEncoding {
  func encode(_ urlRequest: inout URLRequest, parameters: [String: String]) throws
}

struct MDRecordURLEncoding: MDRecordParameterEncoding {
  
  static var `default`: MDRecordURLEncoding { return MDRecordURLEncoding() }
  
  func encode(_ urlRequest: inout URLRequest, parameters: [String: String]) throws {
    
    guard let url = urlRequest.url else {
      throw MDRecordRequestError.parameterEncodingFailed(reason: .missingURL)
    }
    
    let methods = [MDRecordHTTPMethod.get.rawValue, MDRecordHTTPMethod.post.rawValue]
    
    guard let method = urlRequest.httpMethod,
      methods.contains(method) else {
        throw MDRecordRequestError.methodRestriction(supportedMethod: "GET & POST only")
    }
    
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      throw MDRecordRequestError.invalidURL(url: url)
    }
    var queryItems = components.queryItems ?? []
    for (key, value) in parameters {
      let queryItem = URLQueryItem(name: key, value: value)
      queryItems.append(queryItem)
    }
    components.queryItems = queryItems
    
    if method == MDRecordHTTPMethod.get.rawValue {
      urlRequest.url = components.url
    } else {
      if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
      }
      urlRequest.httpBody = components.percentEncodedQuery.flatMap {
        $0.data(using: .utf8)
      }
    }
  }
}

struct JSONEncoding: MDRecordParameterEncoding {
  
  static var `default`: JSONEncoding { return JSONEncoding() }
  
  func encode(_ urlRequest: inout URLRequest, parameters: [String: String]) throws {
    guard urlRequest.url == nil else {
      throw MDRecordRequestError.parameterEncodingFailed(reason: .missingURL)
    }
    
    do {
      let data = try JSONEncoder().encode(parameters)
      if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      urlRequest.httpBody = data
    } catch {
      throw MDRecordRequestError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
    }
  }
}

struct PropertyListEncoding: MDRecordParameterEncoding {
  
  static var `default`: PropertyListEncoding { return PropertyListEncoding() }
  
  func encode(_ urlRequest: inout URLRequest, parameters: [String: String]) throws {
    guard urlRequest.url == nil else {
      throw MDRecordRequestError.parameterEncodingFailed(reason: .missingURL)
    }
    
    do {
      let data = try PropertyListSerialization.data(fromPropertyList: parameters, format: .xml, options: 0)
      if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
        urlRequest.setValue("application/x-plist", forHTTPHeaderField: "Content-Type")
      }
      
      urlRequest.httpBody = data
    } catch {
      throw MDRecordRequestError.parameterEncodingFailed(reason: .propertyListEncodingFailed(error: error))
    }
  }
}
