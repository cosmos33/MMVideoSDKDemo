//
//  MDAlbumVideoDynamicEffectModel.m
//  MomoChat
//
//  Created by sunfei on 2018/9/12.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MDAlbumVideoDynamicEffectModel.h"
#import <RecordSDK/MDAlbumPlayerTransitionAnimation.h>
#import "MDDownLoadManager.h"
#import "MDMusicCollectionItem.h"
#import "MDMusicBVO.h"
#import <RecordSDK/NSString+MDMD5Hash.h>
#import <RecordSDK/MDRDynamicEffectParams.h>

#define DYNAMIC_RESOURCE_ROOTPATH \
([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,\
NSUserDomainMask, YES) objectAtIndex:0]\
stringByAppendingString:@"/DYNAMIC_RESOURCE_CACHE"]) \

@interface MDAlbumVideoDynamicEffectModel() <MDDownLoderDelegate>

@property (nonatomic, strong) MDDownLoadManager *downLoadManager;
@property (nonatomic, copy) void(^downloadComplete)(MDAlbumVideoDynamicEffectModel *model, BOOL result);
@property (nonatomic, copy) void(^progressBlock)(float progress);

@end

@implementation MDAlbumVideoDynamicEffectModel

+ (instancetype)randomEffectModel {
    NSArray *classArray = @[[MDAlbumVideoRTLDynamicEffectModel class],
                            [MDAlbumVideoSoftDynamicEffectModel class],
                            [MDAlbumVideoFastDynamicEffectModel class],
                            [MDAlbumVideoShowDynamicEffectModel class]];
    Class class = classArray[arc4random_uniform(4)];
    return [[class alloc] init];
}

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon animationType:(NSString *)animationType {
    self = [super init];
    if (self) {
        _title = title;
        _icon = icon;
        _selectedIcon = selectedIcon;
        _animationType = animationType;
    }
    return self;
}

- (BOOL)isNeedDownload {
    if (!self.downloaderModel || self.downloaderModel.url.length == 0 ) {
        return NO;
    }
    
    return ![[NSFileManager defaultManager] fileExistsAtPath:self.downloaderModel.resourcePath];
}

- (MDDownLoadManager *)downLoadManager {
    if (!_downLoadManager) {
        _downLoadManager = [[MDDownLoadManager alloc] initWithDelegate:self];
    }
    return _downLoadManager;
}

- (void)startDownloadWithCompletion:(void (^)(MDAlbumVideoDynamicEffectModel *, BOOL))complete {
    [self startDownloadWithProgress:nil completion:complete];
}

- (void)startDownloadWithProgress:(void(^)(float))progress completion:(void(^)(MDAlbumVideoDynamicEffectModel *model, BOOL result))complete {
    if (!self.downloaderModel || self.downloaderModel.url.length == 0) {
        return;
    }
    
    if (self.isDownloading) {
        return;
    }
    
    self.progressBlock = progress;
    self.downloadComplete = complete;
    [self.downLoadManager downloadItem:self.downloaderModel];
}

- (void)cancelDownload {
    if (!self.downloaderModel) {
        return;
    }
    [self.downLoadManager cancelDownloadingItem:self.downloaderModel];
}

- (BOOL)isDownloading {
    if (!self.downloaderModel) {
        return NO;
    }
    return [self.downLoadManager isDownloadingItem:self.downloaderModel];
}

#pragma mark - MDDownLoadManager Methods

- (void)downloaderStart:(id)sender downloadWithItem:(MDDownLoaderModel *)item {
    
}

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item downloadEnd:(BOOL)result {
    self.downloadComplete ? self.downloadComplete(self, result) : nil;
}

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item progress:(float)progress {
    self.progressBlock ? self.progressBlock(progress) : nil;
}

@end

@implementation MDAlbumVideoRTLDynamicEffectModel

- (instancetype)init {
    return [super initWithTitle:@"简单"
                           icon:[UIImage imageNamed:@"horizontalDynamicEffectIcon"]
                   selectedIcon:nil
                  animationType:kAlbumPlayerAnimationTypeFromRightToLeft];
}

@end

@implementation MDAlbumVideoBTTDynamicEffectModel

- (instancetype)init {
    return [super initWithTitle:@"纵向"
                           icon:nil
                   selectedIcon:nil
                  animationType:kAlbumPlayerAnimationTypeFromBottomToTop];
}

@end


#define kModelMusicID               @"5b9bc00c55cdf";
#define kModelMusicUrl              @"http://img.momocdn.com/chataudio/90/A1/90A19A90-0F9F-1678-AB19-620D77FAE7ED20180914.mp3";
#define kModelMusicCover            @"http://img.momocdn.com/feedimage/4A/13/4A13EBE4-FED8-D8C7-32BB-4B9503010C6C20180914_250x250.jpg";
#define kModelMusicTitle            @"比心-麦小兜"
#define kModelMusicDuration         (23)

@implementation MDAlbumVideoScatterDynamicEffectModel

- (instancetype)init {
    return [super initWithTitle:@"四散"
                           icon:[UIImage imageNamed:@"scatterDynamicEffectIcon"]
                   selectedIcon:[UIImage imageNamed:@"scatterDynamicEffectIconSelected"]
                  animationType:kAlbumPlayerAnimationTypeScatter];
}



@end

@implementation MDAlbumVideoShowDynamicEffectModel {
    MDDownLoaderModel *_downloaderModel;
    MDMusicCollectionItem *_musicItem;
}

- (instancetype)init {
    self = [super initWithTitle:@"秀动"
                           icon:[UIImage imageNamed:@"showDynamicEffectIcon"]
                   selectedIcon:nil
                  animationType:kAlbumPlayerAnimationTypeShow];
    
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath1 = [NSURL fileURLWithPath:self.loopupImage1Path];
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath2 = [NSURL fileURLWithPath:self.loopupImage2Path];
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath3 = [NSURL fileURLWithPath:self.loopupImage3Path];
    
    return self;
}

- (MDDownLoaderModel *)downloaderModel {
    if (!_downloaderModel) {
        MDDownLoaderModel *model = [[MDDownLoaderModel alloc] init];
        model.url = @"http://img.momocdn.com/momentlib/8A/01/8A014DA7-D5D8-D4B2-3EC3-EE8D8AE22D0120180919.zip";
        model.downLoadFileSavePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[model.url md_MD5]];
        model.resourcePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[[model.url lastPathComponent] stringByDeletingPathExtension]];
        _downloaderModel = model;
    }
    return _downloaderModel;
}

- (MDMusicCollectionItem *)musicItem {
    if(!_musicItem) {
        _musicItem = [[MDMusicCollectionItem alloc] init];
        
        MDMusicBVO *bvo = [[MDMusicBVO alloc] init];
        bvo.musicID = kModelMusicID;
        bvo.remoteUrl = kModelMusicUrl;
        bvo.title = kModelMusicTitle;
        bvo.cover = kModelMusicCover;
        bvo.duration = kModelMusicDuration;
        
        _musicItem.musicVo = bvo;
    }
    return _musicItem;
}

- (NSString *)loopupImage1Path {
    return [self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Lookup/lookup1.jpg"];
}

- (NSString *)loopupImage2Path {
    return [self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Lookup/lookup2.jpg"];
}

- (NSString *)loopupImage3Path {
    return [self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Lookup/lookup3.jpg"];
}

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item downloadEnd:(BOOL)result {
    
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath1 = [NSURL fileURLWithPath:self.loopupImage1Path];
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath2 = [NSURL fileURLWithPath:self.loopupImage2Path];
    MDRAlbumVideoShowDynamicEffectParams.lookupImagePath3 = [NSURL fileURLWithPath:self.loopupImage3Path];
    
    [super downloader:sender withItem:item downloadEnd:result];
}

@end

@implementation MDAlbumVideoFastDynamicEffectModel {
    MDDownLoaderModel *_downloaderModel;
}

- (instancetype)init {
    return [super initWithTitle:@"欢快"
                           icon:[UIImage imageNamed:@"livelyDynamicEffectIcon"]
                   selectedIcon:nil
                  animationType:kAlbumPlayerAnimationTypeTemplate1];
}

- (MDDownLoaderModel *)downloaderModel {
    if (!_downloaderModel) {
        MDDownLoaderModel *model = [[MDDownLoaderModel alloc] init];
        model.url = @"https://img.momocdn.com/momentlib/FC/A4/FCA462F7-1FD8-BC05-81B2-94CC97CB95EA20181121.zip";
        model.downLoadFileSavePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[model.url md_MD5]];
        model.resourcePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[[model.url lastPathComponent] stringByDeletingPathExtension]];
        _downloaderModel = model;
    }
    return _downloaderModel;
}

- (NSURL *)decorationPath {
    return [NSURL fileURLWithPath:[self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Pre"]];
//    return [[NSBundle.mainBundle URLForResource:@"oldFilm2" withExtension:@"bundle"] URLByAppendingPathComponent:@"Pre"];
}

- (NSString *)momoID {
//    return [MDContext currentUser].momoid;
    return nil;
}

- (NSString *)nickname {
//    return [[[[MDContext currentUser] personalManager] personalProfile] getDisplayName];
    return nil;
}

@end

@implementation MDAlbumVideoSoftDynamicEffectModel {
    MDDownLoaderModel *_downloaderModel;
}

- (instancetype)init {
    self = [super initWithTitle:@"轻松"
                           icon:[UIImage imageNamed:@"lightDynamicEffectIcon"]
                   selectedIcon:nil
                  animationType:kAlbumPlayerAnimationTypeTemplate2];
    
    MDRAlbumVideoSoftDynamicEffectParams.lookupImagePath = self.loopupImagePath;
    
    return self;
}

- (MDDownLoaderModel *)downloaderModel {
    if (!_downloaderModel) {
        MDDownLoaderModel *model = [[MDDownLoaderModel alloc] init];
        model.url = @"https://img.momocdn.com/momentlib/2E/6D/2E6D6718-3D2B-7492-717F-356BA7BD368D20181121.zip";
        model.downLoadFileSavePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[model.url md_MD5]];
        model.resourcePath = [DYNAMIC_RESOURCE_ROOTPATH stringByAppendingPathComponent:[[model.url lastPathComponent] stringByDeletingPathExtension]];
        _downloaderModel = model;
    }
    return _downloaderModel;
}

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item downloadEnd:(BOOL)result {
    
    MDRAlbumVideoSoftDynamicEffectParams.lookupImagePath = self.loopupImagePath;
    
    [super downloader:sender withItem:item downloadEnd:result];
}

- (NSURL *)decorationPath {
    return [NSURL fileURLWithPath:[self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Pre"]];
//    return [[NSBundle.mainBundle URLForResource:@"oldFilm" withExtension:@"bundle"] URLByAppendingPathComponent:@"Pre"];
}

- (NSURL *)curtainFallImagePath {
    return [NSURL fileURLWithPath:[self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Post/overlayPost/overlayPost_000.png"]];
//    return [[NSBundle.mainBundle URLForResource:@"oldFilm" withExtension:@"bundle"] URLByAppendingPathComponent:@"Post/overlayPost/overlayPost_000.png"];
}

- (NSURL *)loopupImagePath {
    return [NSURL fileURLWithPath:[self.downloaderModel.resourcePath stringByAppendingPathComponent:@"Pre/lookup.png"]];
//    return [[NSBundle.mainBundle URLForResource:@"oldFilm" withExtension:@"bundle"] URLByAppendingPathComponent:@"Pre/lookup.png"];
}

@end
