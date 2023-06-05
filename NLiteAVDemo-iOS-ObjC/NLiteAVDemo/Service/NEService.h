// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 请求服务
 */

#import <Foundation/Foundation.h>
#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEService : NSObject

+ (instancetype)shared;
- (void)runTask:(id<NEServiceTask>)task completion:(NERequestHandler)completion;
@end

NS_ASSUME_NONNULL_END
