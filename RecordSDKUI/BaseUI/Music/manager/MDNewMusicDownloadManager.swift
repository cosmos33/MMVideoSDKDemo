//
//  MDNewMusicDownloadManager.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/16.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc protocol MDNewMusicDownloadManagerDelegate: NSObjectProtocol {
    func startDownload(item: MDMusicBVO)
    func finishDownload(item: MDMusicBVO, fileUrl: URL?, success: Bool)
}

@objc class MDNewMusicDownloadManager: NSObject {
    
    @objc static let shared = MDNewMusicDownloadManager()
    
    @objc func requestRecommendMusic(with callback: @escaping ((String?, Error?) -> Void)) {
        let configPath = Bundle.main.url(forResource: "RecomendMusics", withExtension: "geojson")
        let local = MDRecordResource(remoteURL: configPath!, customParams: [:]) { data in
            String(data: data, encoding: .utf8)
        }
        MDRecordLocalFileFetcher().load(resource: local) { result in
            callback(result.value, result.error)
        }
    }
    
    @objc func download(_ item: MDMusicBVO, bind targetObj: MDNewMusicDownloadManagerDelegate) {
        let resourcePath = MDNewMusicDownloadManager.resoucePath(for: item)
        let _ = resourcePath.map {
            targetObj.startDownload(item: item)
            MDRecordResourceDownloader.shared.download(url: URL(string: item.remoteUrl)!, dst:$0)  { (result) in
                DispatchQueue.main.async {
                    targetObj.finishDownload(item: item, fileUrl: result.value, success: result.isSuccess)
                }
            }
        }
    }
    
    @objc func download(_ item: MDMusicBVO, completion: @escaping (MDMusicBVO, URL?, Bool) -> Void) {
        let resourcePath = MDNewMusicDownloadManager.resoucePath(for: item)
        let _ = resourcePath.map {
            MDRecordResourceDownloader.shared.download(url: URL(string: item.remoteUrl)!, dst:$0)  { (result) in
                DispatchQueue.main.async {
                    completion(item, result.value, result.isSuccess)
                }
            }
        }
    }
 
    @objc static func resoucePath(for item: MDMusicBVO) -> URL? {
        let url = URL(string: item.remoteUrl)!
        
        let extensionStr = url.pathExtension
        let name = item.musicID + "." + extensionStr
        let path = URL(fileURLWithPath:NSHomeDirectory()).appendingPathComponent("Library/Application Support/VideoBackgroundMusic/")
        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        let resourcePath = path.appendingPathComponent(name)
        return resourcePath
    }
}
