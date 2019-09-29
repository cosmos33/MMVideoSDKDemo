//
//  MDFaceDecorationLoader.h
//  MDRecordSDK
//
//  Created by sunfei on 2019/7/29.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDFaceDecorationItemI: NSObject

//@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *tag;
//@property (nonatomic, copy) NSString *zip_url;
//@property (nonatomic, copy) NSString *image_url;
//@property (nonatomic, copy) NSString *app_version;
//@property (nonatomic, copy) NSString *app_version_high_limit;
//@property (nonatomic, copy) NSString *op_mmid;
//@property (nonatomic, copy) NSString *sound;
//@property (nonatomic, copy) NSString *parent_care;
//@property (nonatomic, copy) NSString *cate;
//@property (nonatomic, copy) NSString *frontcate;
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *
//@property (nonatomic, copy) NSString *

@end

@interface MDFaceDecorationClass: NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *selectedImageURL;

@end



@interface MDFaceDecorationLoader : NSObject

- (void)fetchDecorationsWithCompletion:(void(^)(NSDictionary * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
