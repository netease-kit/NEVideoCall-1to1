// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AppKey.h"
#import "NEServiceTask.h"
#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

// 请求闭包
typedef void (^NERequestHandler)(NSDictionary *_Nullable data, NSError *_Nullable error);
static NSString *baseURL = kApiHost;

@interface NETask : NSObject <NEServiceTask>
+ (instancetype)task;
+ (instancetype)taskWithSubURL:(NSString *__nullable)subURL;
+ (instancetype)taskWithURLString:(NSString *)urlString;
- (void)postWithCompletion:(NERequestHandler)completion;

- (NSString *)getURL;

@end

NS_ASSUME_NONNULL_END
