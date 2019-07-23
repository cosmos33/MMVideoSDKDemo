//
//  DynamicExpressionLoader.swift
//  MDRecordSDK
//
//  Created by sunfei on 2019/3/17.
//  Copyright © 2019 sunfei. All rights reserved.
//

import UIKit

@objc class ExpressionLoader: NSObject {
    @objc static func dynamicLoadExpression(completion:@escaping (String?, Error?) -> Void) {
        let url = Bundle.main.url(forResource: "DynamicExpression", withExtension: "geojson")
        loadExpression(url!, completion: completion)
    }
    
    @objc static func staticLoadExpression(completion:@escaping (String?, Error?) -> Void) {
        let url = Bundle.main.url(forResource: "StaticExpression", withExtension: "geojson")
        loadExpression(url!, completion: completion)
    }
    
    static func loadExpression(_ url: URL, completion: @escaping (String?, Error?) -> Void) {
        let local = MDRecordResource(remoteURL: url, customParams: [:]) { data in
            String(data: data, encoding: .utf8)
        }
        
        MDRecordLocalFileFetcher().load(resource: local) { (result) in
            completion(result.value, result.error)
        }
    }
}
