//
//  MDAssetPickerController.m
//  MDChat
//
//  Created by YU LEI on 2017/6/2.
//  Copyright © 2017年 sdk.com. All rights reserved.
//


#import "MDAssetPickerController.h"
#import "MDPreviewPageViewController.h"
#import <Photos/Photos.h>
#import "MDAssetSelectState.h"
#import "MDAssetUtility.h"
#import "MDAssetPreviewController.h"

@interface MDAssetPickerController () <MDAssetPreviewControllerDelegate>
@property (nonatomic, assign) BOOL      originalStatusHidden;
@property (nonatomic, assign) NSInteger currentIdx;
@property (nonatomic, strong) MDAssetSelectState *assetState;
@end

@implementation MDAssetPickerController

- (id)initPreviewWithDelegate:(id <MDAssetPickerControllerDelegate>)delegate currentIndex:(NSInteger)idx {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.currentIdx = idx;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.originalStatusHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusHidden animated:NO];
}


- (void)commonConfigure
{
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    MDAssetPreviewController *previewController = [[MDAssetPreviewController alloc] initWithCurrentIndexPath:[NSIndexPath indexPathForRow:self.currentIdx inSection:0]];
    previewController.delegate = self;
    previewController.assetState = self.assetState;
    previewController.enableOrigin = YES;
    previewController.isOrigin = self.isOrigin;
    
    __weak typeof(self) weakSelf = self;
    [[MDAssetUtility sharedInstance] fetchAllAssetsWithMediaType:MDAssetMediaTypeOnlyPhoto completeBlock:^(NSArray<MDPhotoItem *> *itemArray) {
        previewController.fetchedAssets = itemArray;
        for (int i = 0; i < weakSelf.selectedArr.count; i++) {
            NSNumber *idx = weakSelf.selectedArr[i];
            MDPhotoItem *item = [itemArray objectAtIndex:idx.integerValue defaultValue:nil];
            if (item) {
                [weakSelf.assetState changeSelectState:YES forAsset:item indexPath:[NSIndexPath indexPathForRow:idx.integerValue inSection:0]];
                item.selected = YES;
                item.idxNumber = i+1;
            }
        }
        [weakSelf setViewControllers:@[previewController] animated:NO];
    }];
}

#pragma mark - MDAssetPreviewControllerDelegate

- (void)assetPreviewControllerDidFinish:(MDAssetPreviewController *)controller {
    id<MDAssetPickerControllerDelegate> delegate = (id <MDAssetPickerControllerDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(assetPickerController:didFinishPickingMediaWithAssets:)]) {
        NSMutableArray *itemArray = [NSMutableArray array];
        for (MDAssetStateModel *model in self.assetState.selectedArray) {
            [itemArray addObjectSafe:model.assetItem];
        }
        [delegate assetPickerController:self didFinishPickingMediaWithAssets:itemArray];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Accessors -

- (void)setSelectionLimit:(NSInteger)selectionLimit
{
    if (_selectionLimit != selectionLimit) {
        _selectionLimit = selectionLimit;
        self.assetState.selectionLimit = _selectionLimit;
    }
}

- (MDAssetSelectState *)assetState {
    if (!_assetState) {
        _assetState = [[MDAssetSelectState alloc] init];
    }
    return _assetState;
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
