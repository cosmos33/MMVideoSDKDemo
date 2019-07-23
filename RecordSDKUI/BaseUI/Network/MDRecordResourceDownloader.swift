//
//  ResourceDownloader.swift
//  ImageAdviser
//
//  Created by sunfei on 06/02/2018.
//  Copyright © 2018 DEMO. All rights reserved.
//

import Darwin
import Foundation

typealias Completion = (MDRecordResult<URL>) -> Void

struct MDRecordResourceTask: Equatable, Hashable, MDRecordRevokable {
  private static var globalTaskAmount: OSAtomic_int64_aligned64_t = 0
  
  private let taskIdentifier: Int64 = OSAtomicAdd64(1, &globalTaskAmount)
  let resourceURL: URL
  
  var hashValue: Int {
    return Int(taskIdentifier)
  }

  static func == (lhs: MDRecordResourceTask, rhs: MDRecordResourceTask) -> Bool {
    return lhs.taskIdentifier == rhs.taskIdentifier
  }
  
  func cancel() {
    MDRecordResourceDownloader.shared.cancel(task: self)
  }
}

struct MDRecordResourceTrace {
  var callbacks: [MDRecordResourceTask: Completion] = [:]
  let downloadTask: URLSessionDownloadTask
  
  init(downloadTask: URLSessionDownloadTask) {
    self.downloadTask = downloadTask
  }
}

class MDRecordResourceDownloader {
  static let shared = MDRecordResourceDownloader()
  private var resourceTraces: [URL: MDRecordResourceTrace] = [:]
  
  @discardableResult
  func download(url: URL, dst: URL, callback: @escaping Completion) -> MDRecordRevokable {
    let task = MDRecordResourceTask(resourceURL: url)
    if var trace = resourceTraces[url] {
      trace.callbacks[task] = callback
      resourceTraces[url] = trace
    } else {
      let createTask: (URLRequest) -> URLSessionDownloadTask = { request in
        let downloadTask =
          URLSession.shared.downloadTask(with: request, completionHandler: { (temporaryURL, response, error) in
            if let err = error {
              self.notify(remoteURL: url, result: .failure(err))
              return
            }
            
            if let res = response as? HTTPURLResponse,
              res.statusCode >= 400 {
                // response error
                let err: MDRecordRequestError = .responseValidationFailed(reason: .unacceptableStatusCode(code: res.statusCode))
                self.notify(remoteURL: url, result: .failure(err))
                return
            }
            
            guard let tmpURL = temporaryURL else {
              let err: MDRecordRequestError = .responseValidationFailed(reason: .dataFileNil)
              self.notify(remoteURL: url, result: .failure(err))
              return
            }
            
            do {
              try FileManager.default.copyItem(at: tmpURL, to: dst)
              self.notify(remoteURL: url, result: .success(dst))
            } catch {
              self.notify(remoteURL: url, result: .failure(error))
            }
          })
        return downloadTask
      }
      
      let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
      let downloadTask = createTask(request)
      var trace = MDRecordResourceTrace(downloadTask: downloadTask)
      trace.callbacks[task] = callback
      resourceTraces[url] = trace
      downloadTask.resume()
    }
    return task
  }
  
  func cancel(task: MDRecordResourceTask) {
    let url = task.resourceURL
    guard var trace = resourceTraces[url] else {
      return
    }
    guard let callback = trace.callbacks[task] else {
      return
    }
    callback(.failure(MDRecordRequestError.cancel))
    trace.callbacks[task] = nil
    if trace.callbacks.isEmpty {
      trace.downloadTask.cancel()
      resourceTraces[url] = nil
    }
  }
  
  func notify(remoteURL: URL, result: MDRecordResult<URL>) {
    guard let trace = resourceTraces[remoteURL] else {
      return
    }
    for callback in trace.callbacks.values {
      callback(result)
    }
  }
}
