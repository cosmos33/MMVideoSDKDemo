//
//  MDMomentExpressionView.m
//  MDChat
//
//  Created by Leery on 16/7/25.
//  Copyright © 2016年 sdk.com. All rights reserved.
//

#import "MDMomentExpressionViewController.h"
#import "MDMomentExpressionView.h"
#import "MDMomentExpressionCellModel.h"
#import "MDDownLoadManager.h"
#import <MMFoundation/MMFoundation.h>
#import "MDRecordContext.h"
#import "Toast/Toast.h"
#import "MDPublicSwiftHeader.h"
@import RecordSDK;

#if !__has_feature(objc_arc)
#error MDMomentExpressionViewController must be built with ARC.
#endif

#define EXPRESSION_ROOTPATH \
([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,\
                                       NSUserDomainMask, YES) objectAtIndex:0]\
  stringByAppendingString:@"/expressionCache"]) \

@interface MDMomentExpressionViewController ()<MDMomentExpressionViewDelegate, MDDownLoderDelegate>
@property (nonatomic ,strong) MDMomentExpressionView *expressionView;
@property (nonatomic ,strong) NSMutableArray *picDatesArray;
@property (nonatomic ,copy) ExpressionViewSelectBlock expressionViewSelectBlock;
@property (nonatomic, strong) MDDownLoadManager     *downLoadManager;
@property (nonatomic, strong) NSString              *rootPath;
@property (nonatomic, assign) BOOL                  isDynamicDecoratorMode;

@end

@implementation MDMomentExpressionViewController

#pragma mark - init

- (instancetype)initWithSelectBlock:(ExpressionViewSelectBlock)block {
    if(self = [super init]){
        self.expressionViewSelectBlock = block;
        self.rootPath = EXPRESSION_ROOTPATH;
    }
    
    return self;
}

- (instancetype)initDynamicDecoratorWithSelectBlock:(ExpressionViewSelectBlock)block {
    
    self = [self initWithSelectBlock:block];
    self.isDynamicDecoratorMode = YES;
    
    return self;
}

#pragma mark - 接口
- (void)show {
    
    //api 请求
    [self requestMomentExpressions];

    self.expressionView.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.expressionView.alpha = 1.0;
    } completion:nil];
    
}

- (void)hide {
    
    _expressionView.alpha = 1.0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.expressionView.alpha = 0;
    } completion:^(BOOL finished) {
        //显示状态栏
        [self.expressionView removeFromSuperview];
        self.expressionView = nil;
    }];
}

- (void)setBackGroundViewWithImage:(UIImage *)image {
    [self.expressionView setBackGroundViewWithImage:image];
}

#pragma mark - API

- (void)requestMomentExpressions {
    if (self.isDynamicDecoratorMode) {
        [ExpressionLoader dynamicLoadExpressionWithCompletion:^(NSString * json, NSError * error) {
            if (json && !error) {
                NSDictionary *dateDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                [self requestSuccess:dateDict];
            } else {
                [self requestError:error];
            }
        }];
    } else {
        [ExpressionLoader staticLoadExpressionWithCompletion:^(NSString * json, NSError * error) {
            if (json && !error) {
                NSDictionary *dateDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                [self requestSuccess:dateDict];
            } else {
                [self requestError:error];
            }
        }];
    }
}

- (void)requestSuccess:(NSDictionary *)dateDict {
   
    [self.picDatesArray removeAllObjects];
    
    if(dateDict && dateDict.count) {
        NSArray *tagsArray = [dateDict arrayForKey:@"tags" defaultValue:nil];
        
        for (NSDictionary *tagInfo in tagsArray) {
            
            if ([tagInfo isKindOfClass:[NSDictionary class]]) {
                
                MDMomentExpressionCellModel *model = [MDMomentExpressionCellModel eta_modelFromDictionary:tagInfo];
                
                if ([model.zipUrl isNotEmpty]) {
                    
                    NSString *saveFileName = [model.zipUrl md_MD5];
                    NSString *finalResourceName = [[model.zipUrl lastPathComponent] stringByDeletingPathExtension];
                    
                    MDDownLoaderModel *downLoadItem = [MDDownLoaderModel new];
                    downLoadItem.url = model.zipUrl;
                    downLoadItem.downLoadFileSavePath = [self.rootPath stringByAppendingPathComponent:saveFileName];
                    downLoadItem.resourcePath = [self.rootPath stringByAppendingPathComponent:finalResourceName];
                    model.downLoadModel = downLoadItem;
                }
                
                [self.picDatesArray addObjectSafe:model];
            }
        }
    }
    [self.expressionView setPicDatesArrayWithArray:self.picDatesArray];
}

- (void)requestError:(NSError *)error {
    [[UIApplication sharedApplication].delegate.window makeToast:error.localizedDescription ?: @"资源加载失败" duration:1.5f position:CSToastPositionCenter];
}

- (NSMutableArray *)picDatesArray {
    if(!_picDatesArray) {
        _picDatesArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _picDatesArray;
}

#pragma mark - MDMomentExpressionViewDelegate
- (void)closeEventAction {
    if(self.expressionViewSelectBlock) {
        self.expressionViewSelectBlock(nil);
        [self hide];
    }
}

- (void)collectionViewDidSelectDateArrayAtIndexUrlDictionary:(NSDictionary *)urlDict{
    
    //先检查是否为动态表情, 如果是动态表情, 但本地不存在, 则去下载; 如果是静态表情或者动态表情已经下载则直接应该
    BOOL needApplyExpression = YES;
    
    MDMomentExpressionCellModel *model = [urlDict objectForKey:@"data"];
    if ([model.zipUrl isNotEmpty]) {
        BOOL isFileExist= [[NSFileManager defaultManager] fileExistsAtPath:model.downLoadModel.resourcePath];
        if (!isFileExist) {
            [self downLoadZipWithModel:model];
        }
        
        needApplyExpression = isFileExist;
    }
    
    if (needApplyExpression && self.expressionViewSelectBlock) {

        self.expressionViewSelectBlock(urlDict);
        [self hide];
    }
}

- (void)downLoadZipWithModel:(MDMomentExpressionCellModel*)cellModel {
    
    NSString *url = cellModel.downLoadModel.url;
    if ([url isNotEmpty]) {
        [self.downLoadManager downloadItem:cellModel.downLoadModel];
    }
}

#pragma mark - 懒加载UI
- (MDMomentExpressionView *)expressionView {
    if(!_expressionView) {
        _expressionView = [[MDMomentExpressionView alloc] initWithDelegate:self];
        _expressionView.alpha = 0;
//        UIWindow *window = [MDContext sharedAppDelegate].window;
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:_expressionView];
    }
    return _expressionView;
}

-(MDDownLoadManager *)downLoadManager {
    
    if (!_downLoadManager) {
        
        _downLoadManager = [[MDDownLoadManager alloc] initWithDelegate:self];
    }
    
    return _downLoadManager;
}

#pragma mark - MDDownLoderDelegate
- (NSString*)downloader:(id)sender fileSavePathForItem:(MDDownLoaderModel*)item {

    MDMomentExpressionCellModel *targetModel = nil;
    for (MDMomentExpressionCellModel *cellModel in self.picDatesArray) {
        if ([cellModel.downLoadModel isEqual:item]) {
            targetModel = cellModel;
        }
    }
    
    NSString *fileName = [item.url md_MD5];
    NSString *filePath = [self.rootPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

- (void)downloaderStart:(id)sender downloadWithItem:(MDDownLoaderModel *)item {
    
    [self refreshViewWithItem:item];
}

- (void)downloader:(id)sender withItem:(MDDownLoaderModel *)item downloadEnd:(BOOL)result {
    
    [self refreshViewWithItem:item];
}

- (void)refreshViewWithItem:(MDDownLoaderModel*)item {
    
    for (MDMomentExpressionCellModel *cellModel in self.picDatesArray) {
        if ([cellModel.downLoadModel isEqual:item]) {
            cellModel.downLoadModel = item;
        }
    }
    
    [self.expressionView refreshView];
}
@end




