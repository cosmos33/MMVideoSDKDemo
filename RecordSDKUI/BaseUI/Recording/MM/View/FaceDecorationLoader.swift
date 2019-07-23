//
//  FaceDecorationLoader.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/17.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc class FaceDecorationLoader: NSObject {
    @objc static func loadFaceDecoration(callback: @escaping (String?, Error?) -> Void) {
        let configPath = Bundle.main.url(forResource: "Decoration_Face", withExtension: "geojson")
        let local = MDRecordResource(remoteURL: configPath!, customParams: [:]) { data in
            String(data: data, encoding: .utf8)
        }
        MDRecordLocalFileFetcher().load(resource: local) { result in
            callback(result.value, result.error)
        }
    }
}

