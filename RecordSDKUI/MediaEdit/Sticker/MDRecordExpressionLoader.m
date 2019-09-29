//
//  MDRecordExpressionLoader.m
//  MDRecordSDK
//
//  Created by sunfei on 2019/9/18.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "MDRecordExpressionLoader.h"

@implementation MDRecordExpressionLoader

+ (void)loadDynamicExpressionWithCompletion:(void(^)(NSString *, NSError *))completion {
    NSURL *localURL = [NSBundle.mainBundle URLForResource:@"DynamicExpression" withExtension:@"geojson"];
    [self loadExpression:localURL completion:completion];
}

+ (void)loadStaticExpressionWithCompletion:(void(^)(NSString *, NSError *))completion {
    NSURL *localURL = [NSBundle.mainBundle URLForResource:@"StaticExpression" withExtension:@"geojson"];
    [self loadExpression:localURL completion:completion];
}

+ (void)loadExpression:(NSURL *)url completion:(void(^)(NSString *, NSError *))completion {
    NSError *error = nil;
    NSString *content = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    completion ? completion(content, error) : nil;
}

@end
