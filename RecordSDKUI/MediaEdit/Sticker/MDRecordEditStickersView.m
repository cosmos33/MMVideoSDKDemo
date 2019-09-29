//
//  MDRecordStickersEditView.m
//  MomoChat
//
//  Created by RFeng on 2019/4/8.
//  Copyright © 2019年 wemomo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Utils.h"
#import <MMFoundation/MMFoundation.h>
#import "MDRecordEditStickersView.h"
#import "MDMomentExpressionCellModel.h"
#import "MDDownLoadManager.h"
#import "MDMomentExpressionCell.h"
#import "MDCollectionHelper.h"
#import "MDRecordEditTItleView.h"
#import "UIView+Corner.h"
#import "UIConst.h"
#import "Toast/Toast.h"
#import "MDRecordExpressionLoader.h"
@import RecordSDK;

#define kStickerCell  @"MDMomentExpressionCell"
#define  KRECORD_EXPRESSION_ROOTPATH \
([[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,\
NSUserDomainMask, YES) objectAtIndex:0]\
stringByAppendingString:@"/expressionCache"]) \

@interface MDRecordEditStickersView()<MDDownLoderDelegate,MDCollectionHelperDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;


@property (nonatomic, assign) BOOL isDynamicDecoratorMode;

@property (nonatomic, copy) NSString *rootPath;

@property (nonatomic, strong) MDCollectionHelper *collectionHelper;

@property (nonatomic, strong) MDDownLoadManager *downLoadManager;

@end

@implementation MDRecordEditStickersView


+ (MDRecordEditStickersView *)imageEditStickersView
{
    MDRecordEditStickersView *view = [[MDRecordEditStickersView alloc] initWithFrame:CGRectMake(0, 0, MDScreenWidth, 172) isDynamicDecoratorMode:NO];
 
    return view;
    
}

- (instancetype)initWithFrame:(CGRect)frame isDynamicDecoratorMode:(BOOL)isDynamicDecoratorMode
{
    if (self = [super initWithFrame:frame]) {
        [self setUpBgView];
        self.isDynamicDecoratorMode = YES;
        self.rootPath = KRECORD_EXPRESSION_ROOTPATH;
        [self layoutUI];
        [self requestMomentExpressions];
    }
    return self;
}

- (void)requestIfNeed
{
    if (self.dataArray.count == 0) {
        [self requestMomentExpressions];
    }
}


- (void)setUpBgView
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    bgView.frame = self.bounds;
    [self addSubview:bgView];
}

#pragma mark - API

- (void)requestMomentExpressions {
    
    if (self.isDynamicDecoratorMode) {
        [MDRecordExpressionLoader loadDynamicExpressionWithCompletion:^(NSString *json, NSError *error) {
            if (json && !error) {
                NSDictionary *dateDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                [self requestSuccess:dateDict];
            } else {
                [self requestError:error];
            }
        }];
    } else {
        [MDRecordExpressionLoader loadStaticExpressionWithCompletion:^(NSString *json, NSError * error) {
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
    
    [self.dataArray removeAllObjects];

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
                
                [self.dataArray addObjectSafe:model];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)requestError:(NSError *)error {
     [[UIApplication sharedApplication].delegate.window makeToast:error.localizedDescription ?: @"资源加载失败" duration:1.5f position:CSToastPositionCenter];
}


- (void)layoutUI
{
    MDRecordEditTItleView *titleView = [[MDRecordEditTItleView alloc] initWithTitles:@[@"贴纸"]];
    [self addSubview:titleView];

    self.collectionView.height = self.height - titleView.height;
    self.collectionView.top = titleView.height;
    [self addSubview:self.collectionView];
    self.collectionHelper = [MDCollectionHelper bindingForCollectionView:self.collectionView sourceList:self.dataArray templateClassNameList:[self classNameCellArray] delegate:self sourceSignal:RACObserve(self, self.dataArray)];
    [self setCornerType:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadius:8];
}



#pragma mark - lazyGetter
- (UICollectionView *)collectionView {
    if(!_collectionView) {
        
        CGFloat cellHeight = 40;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(cellHeight, cellHeight);
        flowLayout.minimumInteritemSpacing = 20;
        flowLayout.minimumLineSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            [_collectionView setPrefetchingEnabled:NO];
        }
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        
    }
    return _collectionView;
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
    
    if (needApplyExpression) {

//        self.expressionViewSelectBlock(urlDict);
//        [self hide];
    }
}

- (void)downLoadZipWithModel:(MDMomentExpressionCellModel*)cellModel {
    
    NSString *url = cellModel.downLoadModel.url;
    if ([url isNotEmpty]) {
        [self.downLoadManager downloadItem:cellModel.downLoadModel];
    }
}

#pragma mark - 懒加载UI


-(MDDownLoadManager *)downLoadManager {
    
    if (!_downLoadManager) {
        
        _downLoadManager = [[MDDownLoadManager alloc] initWithDelegate:self];
    }
    
    return _downLoadManager;
}

#pragma mark - MDDownLoderDelegate
- (NSString*)downloader:(id)sender fileSavePathForItem:(MDDownLoaderModel*)item {
    
    MDMomentExpressionCellModel *targetModel = nil;
    for (MDMomentExpressionCellModel *cellModel in self.dataArray) {
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
    
    for (MDMomentExpressionCellModel *cellModel in self.dataArray) {
        if ([cellModel.downLoadModel isEqual:item]) {
            cellModel.downLoadModel = item;
        }
    }
    
    [self.collectionView reloadData];
}

#pragma mark - collectView delegate

- (NSArray *)classNameCellArray {
    return @[kStickerCell];
}

- (NSString *)collectionCellIdentifier:(MDMomentExpressionCellModel *)item
{
    NSString *identifer = @"";
    if (item) {
        identifer = kStickerCell;
    }
    return identifer;
}

- (NSString *)cellReuseIdentifer:(NSInteger)index
{
    NSString *identifer = @"";
    if ([self.dataArray count] && index < [self.dataArray count]) {
        MDMomentExpressionCellModel *model = [self.dataArray objectAtIndex:index defaultValue:nil];
        identifer = [self collectionCellIdentifier:model];
    }
    return identifer;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count && indexPath.row < self.dataArray.count){
        if(self.delegate && [self.delegate respondsToSelector:@selector(collectionViewDidSelectDateArrayAtIndexUrlDictionary:)]){
            MDMomentExpressionCell *cell = (MDMomentExpressionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            CGPoint center = [cell convertPoint:[cell cellContentView].center toView:self];
            
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
            [dictionary setObjectSafe:[NSValue valueWithCGPoint:center] forKey:@"center"];
            MDMomentExpressionCellModel *model = [self.dataArray objectAtIndex:indexPath.row defaultValue:nil];
            [dictionary setObjectSafe:model forKey:@"data"];
            BOOL needApplyExpression = YES;

            if ([model.zipUrl isNotEmpty]) {
                BOOL isFileExist= [[NSFileManager defaultManager] fileExistsAtPath:model.downLoadModel.resourcePath];
                if (!isFileExist) {
                    [self downLoadZipWithModel:model];
                }
                needApplyExpression = isFileExist;
            }
            if (needApplyExpression) {
                [self.delegate collectionViewDidSelectDateArrayAtIndexUrlDictionary:dictionary];
            }
            
        }

    }
    
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSArray <NSString *> *)editTitles
{
    return @[@"贴纸"];
}

@end
