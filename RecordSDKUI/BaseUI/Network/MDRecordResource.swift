//
//  Resource.swift
//  ImageAdviser
//
//  Created by sunfei on 07/02/2018.
//  Copyright © 2018 DEMO. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]

struct MDRecordResource<T> {
  typealias Parser = (Data) throws -> T?
  
  var remoteURL: URL
  var customParams: [String: String] = [:]
  var parser: Parser
}

enum MDRecordHTTPMethod: String {
  case post = "POST"
  case get = "GET"
}

extension URLRequest {
  init(url: URL, method: MDRecordHTTPMethod, headers: HTTPHeaders? = nil) {
    self.init(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
    httpMethod = method.rawValue
    if let headers = headers {
      for (key, value) in headers {
        setValue(value, forHTTPHeaderField: key)
      }
    }
  }
}

protocol MDRecordFetcher {
  associatedtype ResultType
  
  typealias Completion = (MDRecordResult<ResultType>) -> Void
  
  var headers: HTTPHeaders? { get }
  var params: [String: String] { get }
  
  func load(resource: MDRecordResource<ResultType>, completion: @escaping Completion)
}

extension MDRecordSimpleHTTPFetcher {
  static var get: MDRecordSimpleHTTPFetcher {
    let fetcher = MDRecordSimpleHTTPFetcher()
    fetcher.method = .get
    return fetcher
  }
  
  static var post: MDRecordSimpleHTTPFetcher {
    let fetcher = MDRecordSimpleHTTPFetcher()
    fetcher.method = .post
    return fetcher
  }
}

class MDRecordSimpleHTTPFetcher<T>: MDRecordFetcher {
  var headers: HTTPHeaders?
  var params: [String: String] = [:]
  
  var method: MDRecordHTTPMethod = .get
  let encoding: MDRecordParameterEncoding
  
  init(encoding: MDRecordParameterEncoding) {
    self.encoding = encoding
  }
  
  convenience init() {
    self.init(encoding: MDRecordURLEncoding.default)
  }
  
  func load(resource: MDRecordResource<T>, completion: @escaping (MDRecordResult<T>) -> Void) {
    
    var request = URLRequest(url: resource.remoteURL, method: method, headers: headers)
    
    var parameters: [String: String] = [:]
    parameters.merge(params) { return $1 }
    parameters.merge(resource.customParams) { return $1 }

    do {
      try encoding.encode(&request, parameters: parameters)
    } catch {
      completion(.failure(error))
    }
    
    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      if let err = error {
        completion(.failure(err))
        return
      }
      if let res = response as? HTTPURLResponse,
        res.statusCode >= 400 {
        let err: MDRecordRequestError = .responseValidationFailed(reason: .unacceptableStatusCode(code: res.statusCode))
        completion(.failure(err))
        return
      }
      do {
        guard let parsedData = try data.flatMap(resource.parser) else {
          completion(.failure(MDRecordRequestError.responseSerializationFailed(reson: .jsonSerializationFailed)))
          return
        }
        completion(.success(parsedData))
      } catch {
        completion(.failure(error))
      }
    }).resume()
  }
}

class MDRecordLocalFileFetcher<T>: MDRecordFetcher {
  let headers: HTTPHeaders? = nil
  let params: [String: String] = [:]
  
  func load(resource: MDRecordResource<T>, completion: @escaping (MDRecordResult<T>) -> Void) {
    do {
      let data = try Data(contentsOf: resource.remoteURL)
      guard let parsedData = try resource.parser(data) else {
        completion(.failure(MDRecordRequestError.responseSerializationFailed(reson: .jsonSerializationFailed)))
        return
      }
      completion(.success(parsedData))
    } catch {
      completion(.failure(error))
    }
  }
}
