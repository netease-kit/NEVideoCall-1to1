//
//  NTELoginVC.h
//  NIMAudioChatroom
//
//  Created by Think on 2020/8/18.
//  Copyright © 2020 netease. All rights reserved.
//

/**
 获取验证码VC
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NELoginOptions;

@interface NTELoginVC : UIViewController

/**
 实例化登录视图(输入手机号)
 @param options - 登录配置项
 */
- (instancetype)initWithOptions:(NELoginOptions * _Nullable)options;

@end

NS_ASSUME_NONNULL_END
