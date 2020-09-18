//
//  NEService.h
//  NEDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

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
