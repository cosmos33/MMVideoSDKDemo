//
//  MDSelectedImageItem.h
//  MDChat
//
//  Created by Allen on 10/29/13.
//  Copyright (c) 2013 sdk.com. All rights reserved.
//

/*将一个图片的GUID或者本地的path进行封装，使使用者能够知道它是一个GUID还是一个本地path */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
typedef enum{
    MDSelectedImgaeItemTypeGUID,//当前储存的是guid
    MDSelectedImageItemTypeLocalPath//当前储存的是一个本地的路径
}MDSelectedImageItemType;

typedef enum{
    MDSelectedImageSourceAlbum,
    MDSelectedImageSourceUnknow,
    MDSelectedImageSourceCamera
    
} MDSelectedImageSource;

@interface MDSelectedImageItem : NSObject

@property(nonatomic, copy)  NSString                  *resourceString;//is a path or guid according itemType
@property(nonatomic, assign)MDSelectedImageItemType   itemType;
@property(nonatomic, retain)UIImage                   *originImage;//大图
@property(nonatomic, retain)NSData                    *imgData;
@property(nonatomic, retain)UIImage                   *nailImage;//大图的缩略图
@property(nonatomic, assign)BOOL                      needCompress;//需不需要压缩，localpath的默认都是YES，只有GUID的下完图片用户只是进行了加滤镜的操作时，这个值是NO
@property(nonatomic, copy) NSString                   *md5Hash;
@property(nonatomic, copy) NSString                   *stickerID;
@property(nonatomic, assign)MDSelectedImageSource     source;//图片是拍出来的还是从相册取的
@property(nonatomic, copy) NSString                   *filterName;

@property(nonatomic, assign)BOOL                      shouldSaveToAlbum;//default is NO,  这个字段不保存

@property (getter = isProcessingImg)BOOL processing;

//聊天发图时，是否被选中
@property(nonatomic, assign)BOOL                      choosed;//default is NO,  这个字段不保存
@property(nonatomic, assign) NSUInteger               originLength; //原图的字节数， 这个字段不保存;
@property(nonatomic, copy) NSString                   *localIdentifier;
@property (nonatomic, strong) NSArray                 *faceInfoArray;

+ (id)itemWithGUIDString:(NSString *)aGUID;
+ (id)itemWithLocalPath:(NSString *)aPath;
//类型为localPath
+ (id)itemWithImage:(UIImage *)img;

- (id)initWithGUIDString:(NSString *)aGUID;
- (id)initWithLocalPath:(NSString *)aPath;
- (id)initWithImage:(UIImage *)img;

#pragma mark - 数据结构和dictionary互相转换，丢弃NSData和UIImage
+ (MDSelectedImageItem *)dictionaryToItem:(NSDictionary *)aDic;
+ (NSDictionary *)itemToDictionary:(MDSelectedImageItem *)anItem;
@end
