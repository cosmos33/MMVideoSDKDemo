//
//  MDMusicEditPalletHandler.m
//  MDChat
//
//  Created by YZK on 2018/11/20.
//  Copyright © 2018 sdk.com. All rights reserved.
//

#import "MDMusicEditPalletHandler.h"

#import "MDMusicEditCardCell.h"
#import "MDMusicEditCardItem.h"
#import "MDMusicEditActionCell.h"
#import "MDMusicEditActionItem.h"

#import "MDRecordHeader.h"
#import "MDBackgroundMusicDownloader.h"

@interface MDMusicEditPalletHandler ()
<UICollectionViewDelegate,
UICollectionViewDataSource>
@property (nonatomic ,weak) id<MDMusicEditPalletHandlerDelegate> delegate;
@property (nonatomic ,weak) UICollectionView *collectionView;
@property (nonatomic ,strong) NSArray<MDMusicBaseCollectionItem*> *dataSource;
@property (nonatomic ,strong) NSArray<MDMusicBaseCollectionItem*> *dataList;
@property (nonatomic ,weak) MDMusicCollectionItem *currentMusicItem;
@end

@implementation MDMusicEditPalletHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        [self wrapDataSource];
        [self _loadRecommendData];
    }
    return self;
}

- (void)bindCollectionView:(UICollectionView *)collectionView
                  delagate:(id<MDMusicEditPalletHandlerDelegate>)delegate {
    self.collectionView = collectionView;
    self.delegate = delegate;
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[MDMusicBaseCollectionCell class] forCellWithReuseIdentifier:[MDMusicBaseCollectionCell reuseIdentifier]];
    [collectionView registerClass:[MDMusicEditActionCell class] forCellWithReuseIdentifier:[MDMusicEditActionCell reuseIdentifier]];
    [collectionView registerClass:[MDMusicEditCardCell class] forCellWithReuseIdentifier:[MDMusicEditCardCell reuseIdentifier]];
}

- (void)updateCurrentMusicItem:(MDMusicCollectionItem *)musicItem {
    if (musicItem && ![musicItem isKindOfClass:[MDMusicEditCardItem class]]) {
        musicItem = [MDMusicEditCardItem itemWithCollectionItem:musicItem];
    }
    self.currentMusicItem = musicItem;
    [self wrapDataSource];
    [self.collectionView reloadData];
}

- (void)_loadRecommendData {
    [[MDBackgroundMusicDownloader shared] requestRecommendMusicWithCompletion:^(NSString * _Nonnull json, NSError * _Nonnull error) {
        if (json && !error) {
            NSArray *array = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            [self _coverMusicListDictionaryToItem:array];
        }
    }];
}

- (void)_coverMusicListDictionaryToItem:(NSArray *)musicList {
    NSMutableArray *mutaDataSource = [NSMutableArray arrayWithArray:self.dataList];
    for (NSDictionary *dict in musicList) {
        MDMusicEditCardItem *musicItem = (MDMusicEditCardItem *)[MDMusicEditCardItem converToMusicItemWithDictionary:dict];
        [mutaDataSource addObjectSafe:musicItem];
    }
    self.dataList = [mutaDataSource copy];
    [self wrapDataSource];
    [self.collectionView reloadData];
}

- (void)wrapDataSource {
    NSMutableArray *marr = [NSMutableArray array];
    [marr addObjectSafe:[MDMusicEditActionItem localMusicActionItem]];
    [marr addObjectSafe:[MDMusicEditActionItem clearEditActionItem]];
    if (self.currentMusicItem) {
        [marr addObjectSafe:self.currentMusicItem];
        for (MDMusicCollectionItem *item in self.dataList) {
            if ([item.musicVo.musicID isEqualToString:self.currentMusicItem.musicVo.musicID]) {
                continue;
            }
            [marr addObject:item];
        }
    }else {
        [marr addObjectsFromArray:self.dataList];
    }
    self.dataSource = [marr copy];
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MDMusicBaseCollectionItem *item = [self.dataSource objectAtIndex:indexPath.item];
    MDMusicBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[[item cellClass] reuseIdentifier] forIndexPath:indexPath];
    [cell bindModel:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MDMusicBaseCollectionItem *item = [self.dataSource objectAtIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(collectionViewDidSelectItem:indexPath:)]) {
        [self.delegate collectionViewDidSelectItem:item indexPath:indexPath];
    }
}

@end
