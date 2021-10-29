//
//  NETokenTask.h
//  NLiteAVDemo
//
//  Created by chenyu on 2021/9/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETokenTask : NETask

+ (instancetype)taskWithUid:(NSString *)uid withAppkey:(NSString *)appkey;

@end

NS_ASSUME_NONNULL_END
