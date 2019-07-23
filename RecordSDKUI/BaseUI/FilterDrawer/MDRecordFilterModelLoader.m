//
//  MDRecordFilterModelLoader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/2/15.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordFilterModelLoader.h"

static NSString * const kMDRecordFilterOriginFilterIdentifier = @"原图";

@interface MDRecordFilterModelLoader()

@property (nonatomic,strong) NSDictionary                           *config;

@property (nonatomic,strong) NSMutableArray<MDRecordFilterModel *>  *remoteFilterModels;

@end

@implementation MDRecordFilterModelLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.remoteFilterModels = [NSMutableArray array];
        [self loadConfig];
    }
    return self;
}

- (MDRecordFilterModel *)originFilterModel
{
    MDRecordFilterModel *filterModel = [[MDRecordFilterModel alloc] init];
    filterModel.identifier = kMDRecordFilterOriginFilterIdentifier;
    filterModel.title = @"原图";
    filterModel.filterPath = nil;
    filterModel.iconPath = @"moment_fliter_origin";
    return filterModel;
}

- (void)loadConfig {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *configFile = [bundle pathForResource:@"Config" ofType:@"plist"];
    
    NSDictionary *plist = [NSKeyedUnarchiver unarchiveObjectWithFile:configFile];
    self.config = [plist copy];
    
    [self.remoteFilterModels addObjectsFromArray:[self parseFiltersDictionary:self.config]];
    
    for (MDRecordFilterModel *item in self.remoteFilterModels) {
        item.filterPath = [[self class] resourcePathWithItem:item];
    }
}

+ (NSString *)resourcePathWithItem:(MDRecordFilterModel *)item
{
    NSString *name = [[item.zipUrlString componentsSeparatedByString:@"/"] lastObject];
    name = [name stringByDeletingPathExtension];
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"filters" ofType:@"bundle"] stringByAppendingPathComponent:item.identifier];
    NSString *resourcePath = [path stringByAppendingPathComponent:name];
    
    return resourcePath;
}

- (NSMutableArray<MDRecordFilterModel *> *)parseFiltersDictionary:(NSDictionary *)filtersDictionary {
    NSArray *itemDictArray = filtersDictionary[@"items"];
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *itemDict in itemDictArray) {
        if ([itemDict isKindOfClass:[NSDictionary class]]) {
            MDRecordFilterModel *filterModel = [MDRecordFilterModel filterModelWithDicionary:itemDict];
            [result addObject:filterModel];
        }
    }
    
    return result;
}

- (NSArray<MDRecordFilterModel *> *)getFilterModels {
    NSMutableArray *filterModels = [NSMutableArray array];
    
    [filterModels addObject:[self originFilterModel]];
    
    // 暂时只支持四款
    NSArray *remoteFilterArray = self.remoteFilterModels;
    for (NSInteger i = 0; i < remoteFilterArray.count; ++i) {
        MDRecordFilterModel *filterModel = remoteFilterArray[i];
        [filterModels addObject:filterModel];
    }
    
    return [filterModels copy];
}

- (NSArray<MDRecordFilter *> *)filtersArray {
    NSArray<MDRecordFilterModel *> *models = [self getFilterModels];
    NSMutableArray<MDRecordFilter *> *filters = [NSMutableArray arrayWithCapacity:models.count];
    
    for (MDRecordFilterModel *filterModel in models) {
        MDRecordFilter *aFilter = nil;
        
        if ([filterModel.identifier isEqualToString:kMDRecordFilterOriginFilterIdentifier]) {
//            aFilter = [[MDRecordFilter alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@" "]
//                                                               name:filterModel.title
//                                                           iconPath:@""
//                                                         identifier:filterModel.identifier];
            aFilter = [MDRecordFilter createOriginalEffectFilter];
        }else if (filterModel.filterPath.length > 0) {
            aFilter = [[MDRecordFilter alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filterModel.filterPath isDirectory:YES]
                                                               name:filterModel.title
                                                           iconPath:filterModel.iconUrlString
                                                         identifier:filterModel.identifier];
//            aFilter = [[MDRecordFilter alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filterModel.filterPath isDirectory:YES]];
        }
        [filters addObject:aFilter];
    }
    return filters;
}

+ (void)requeseteRecordChangeFaceData:(void(^)(NSArray *changeFaceArray))finishBlock
{
    if(!finishBlock) return;
    
    NSMutableArray* dataArray = [NSMutableArray array];
    
    MDRecordMakeUpModel* clearFaceModel = [MDRecordMakeUpModel new];
    clearFaceModel.makeUpId = revoke_Id;
    [dataArray addObject:clearFaceModel];
    
    for (NSInteger i = 1; i<=5; i++) {
        MDRecordMakeUpModel* makeUpModel = [MDRecordMakeUpModel new];
        makeUpModel.makeUpId = [NSString stringWithFormat:@"%zd",i];
        makeUpModel.isSelected = NO;
        [dataArray addObject:makeUpModel];
    }
    
    if (finishBlock) {
        finishBlock(dataArray);
    }
}

+ (void)requeseteRecordMakeUpData:(void(^)(NSArray *beautifyArray))finishBlock
{
    if(!finishBlock){return; }
    
    
    NSMutableArray* dataArray = [NSMutableArray array];
    
    MDRecordMakeUpModel* clearFaceModel = [MDRecordMakeUpModel new];
    clearFaceModel.makeUpId = revoke_Id;
    [dataArray addObject:clearFaceModel];
    
    for (NSInteger i = 1; i<=5; i++) {
        MDRecordMakeUpModel* makeUpModel = [MDRecordMakeUpModel new];
        makeUpModel.makeUpId = [NSString stringWithFormat:@"%zd",i];
        makeUpModel.isSelected = NO;
        [dataArray addObject:makeUpModel];
    }
    
    if (finishBlock) {
        finishBlock(dataArray);
    }
}

@end
