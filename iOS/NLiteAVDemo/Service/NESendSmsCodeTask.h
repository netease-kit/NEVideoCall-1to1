//
//  NESendSmsCodeTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NESendSmsCodeTask : NETask
@property (nonatomic, copy) NSString    *req_mobile;
@end

NS_ASSUME_NONNULL_END
