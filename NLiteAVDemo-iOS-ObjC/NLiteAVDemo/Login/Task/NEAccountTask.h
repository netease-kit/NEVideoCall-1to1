//
//  NEAccountTask.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

// 手机验证码登录
@interface NESmsLoginTask : NETask
@property (nonatomic, copy) NSString    *req_mobile;
@property (nonatomic, copy) NSString    *req_smsCode;
@end

// 登出
@interface NELogoutTask : NETask
@property (nonatomic, copy) NSString    *mobile;
@end

// 刷新令牌
@interface NETokenLoginTask : NETask

@end

NS_ASSUME_NONNULL_END
