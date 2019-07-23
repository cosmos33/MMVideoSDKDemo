//
//  FaceDecorationDownloaderBridge.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/16.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc class FaceDecorationDownloaderBridge: NSObject {
    var task: [String: MDRecordRevokable] = [:]
    
    @objc static let shared = FaceDecorationDownloaderBridge()
    
    @objc func download(_ item: MDFaceDecorationItem, completion: @escaping (MDFaceDecorationItem?, Error?) -> Void) {
        let url = URL(string: item.zipUrlStr)
        let dst = URL(fileURLWithPath: MDFaceDecorationFileHelper.zipPath(with: item))
        
        let dir = dst.deletingLastPathComponent()
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
        
        guard let remoteURL = url else {
            completion(nil, nil)
            return
        }
        let task = MDRecordResourceDownloader.shared.download(url: remoteURL, dst: dst) { (result) in
            DispatchQueue.main.async {
                self.task[item.zipUrlStr] = nil
                completion(item, result.error)
            }
        }
        self.task[item.zipUrlStr] = task
    }
    
    @objc func cancel(_ item: MDFaceDecorationItem) {
        let task = self.task[item.zipUrlStr]
        task?.cancel()
    }
}
