// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

// base host
#define BASE_HOST @""

// 隐私政策URL
static NSString *kPrivatePolicyURL =
    @"https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127";
// 用户协议URL
static NSString *kUserAgreementURL = @"http://yunxin.163.com/clauses";

// UIColor宏定义

#define HEXCOLORA(rgbValue, alphaValue)                                \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0  \
                   blue:((float)(rgbValue & 0x0000FF)) / 255.0         \
                  alpha:alphaValue]

#define HEXCOLOR(rgbValue) HEXCOLORA(rgbValue, 1.0)

// 线程
void ntes_main_sync_safe(dispatch_block_t block);
void ntes_main_async_safe(dispatch_block_t block);
