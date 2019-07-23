//
//  MDError.h
//  MDRecordSDK
//
//  Created by sunfei on 2018/12/17.
//  Copyright © 2018 sunfei. All rights reserved.
//

#ifndef MDError_h
#define MDError_h

#import <Foundation/Foundation.h>

typedef NSString *MDErrorDomain;

FOUNDATION_EXPORT MDErrorDomain const MDErrorCode;

NS_ERROR_ENUM(MDErrorCode) {
    NSErrorCodeFailed = -1,  // 未知错误原因
    
    NSErrorCodeAlbumAuthorizationStatusDenied = -200,
    NSErrorCodeCameraAuthorizationStatusDenied = -201,

    MDErrorDropFrame = -1000,
    MDErrorPixelBufferInvalid = -1001,
    MDErrorRenderingWhenEnterBackground = -1002,
    
    // export
    MDErrorExportSessionCanceled = -100,
    MDErrorExportSessionInitializeFailed = -101,
    MDErrorExportSessionUnknown = -102,
    
    MDErrorExportFailedLog = -1200,
};


// filters domain

FOUNDATION_EXPORT MDErrorDomain const kMDErrorDomainDropFrame;
FOUNDATION_EXPORT MDErrorDomain const kMDErrorDomainRender;
FOUNDATION_EXPORT MDErrorDomain const KMDErrorDomainAssetExportSession;
FOUNDATION_EXPORT MDErrorDomain const kMDErrorDomainLog;
FOUNDATION_EXPORT MDErrorDomain const kMDErrorDomainAuthorization;

#endif /* MDError_h */
