//
//  Result.swift
//  ImageAdviser-iOS
//
//  Created by sunfei on 07/02/2018.
//  Copyright © 2018 DEMO. All rights reserved.
//

import Foundation

enum MDRecordResult<T> {
  case success(T)
  case failure(Error)
  
  var isSuccess: Bool {
    if case .success = self {
      return true
    }
    return false
  }
  
  var isFailure: Bool {
    return !isSuccess
  }
  
  var value: T? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }
  
  var error: Error? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }
}

// functional APIs

extension MDRecordResult {
  init(value: () throws -> T) {
    do {
      self = try .success(value())
    } catch {
      self = .failure(error)
    }
  }
  
  func unwrap() throws -> T {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }
  
  // 当 transform异常时，继续抛出
  func map<U>(_ transform: (T) throws -> U) rethrows -> MDRecordResult<U> {
    switch self {
    case .success(let value):
      return try .success(transform(value))
    case .failure(let error):
      return .failure(error)
    }
  }
  
  // 当transform异常时，不再抛出异常
  func flatMap<U>(_ transform: (T) throws -> U) -> MDRecordResult<U> {
    switch self {
    case .success(let value):
      do {
        return try .success(transform(value))
      } catch {
        return .failure(error)
      }
    case .failure(let error):
      return .failure(error)
    }
  }
  
  func mapError<U: Error>(_ transform: (Error) throws -> U) rethrows -> MDRecordResult {
    switch self {
    case .success:
      return self
    case .failure(let error):
      return try .failure(transform(error))
    }
  }
  
  func flatMapError<U: Error>(_ transform: (Error) throws -> U) -> MDRecordResult {
    switch self {
    case .success:
      return self
    case .failure(let error):
      do {
        return try .failure(transform(error))
      } catch {
        return .failure(error)
      }
    }
  }
  
  @discardableResult
  func withValue(_ closure: (T) throws -> Void) rethrows -> MDRecordResult {
    if case let .success(value) = self { try closure(value) }
    return self
  }
  
  @discardableResult
  func withError(_ closure: (Error) throws -> Void) rethrows -> MDRecordResult {
    if case let .failure(error) = self { try closure(error) }
    return self
  }
  
  @discardableResult
  func ifSuccess(_ closure: () throws -> Void) rethrows -> MDRecordResult {
    if isSuccess { try closure() }
    return self
  }
  
  @discardableResult
  func ifFailure(_ closure: () throws -> Void) rethrows -> MDRecordResult {
    if isFailure { try closure() }
    return self
  }
}

extension MDRecordResult: CustomStringConvertible {
  var description: String {
    switch self {
    case .success:
      return "success"
    case .failure:
      return "failure"
    }
  }
}

extension MDRecordResult: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .success(let value):
      return "success: \(value)"
    case .failure(let error):
      return "failure: \(error)"
    }
  }
}
