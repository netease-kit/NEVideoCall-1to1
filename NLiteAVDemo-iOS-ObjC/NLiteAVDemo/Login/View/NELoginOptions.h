// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NELoginBlock)(void);

@interface NELoginOptions : NSObject

@property(nonatomic, copy) NELoginBlock successBlock;  // 登录成功闭包
@property(nonatomic, copy) NELoginBlock failedBlock;   // 登录失败闭包
@property(nonatomic, copy) NELoginBlock cancelBlock;   // 取消登录闭包

@end

NS_ASSUME_NONNULL_END
