//
//  DownloadManagerBridge.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/17.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

class DownloadManagerBridge: NSObject {
    var tasks: [String: MDRecordRevokable] = [:]
    
    @objc static let shared = DownloadManagerBridge()
    
    @objc func download(_ item: MDDownLoaderModel, completion: @escaping (MDDownLoaderModel?, Error?) -> Void) {
        let url = item.url.flatMap(URL.init(string:))
        let dst = item.downLoadFileSavePath.flatMap(URL.init(fileURLWithPath:))
        
        guard let remoteURL = url, var localPath = dst else {
            completion(nil, nil)
            return
        }
        
        if !FileManager.default.fileExists(atPath: localPath.path) {
            try! FileManager.default.createDirectory(at: localPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        localPath = localPath.appendingPathExtension(remoteURL.pathExtension)
        let task = MDRecordResourceDownloader.shared.download(url: remoteURL, dst: localPath) { (result) in
            DispatchQueue.main.async {
                self.tasks[item.url] = nil
                completion(item, result.error)
            }
        }
        
        self.tasks[item.url] = task
    }
    
    @objc func cancel(item: MDDownLoaderModel) {
        let task = self.tasks[item.url]
        task?.cancel()
    }
}
