//
//  UIColor+NTES.h
//  NIMAudioChatroom
//
//  Created by Think on 2020/8/18.
//  Copyright © 2020 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (NTES)

/**
 使用十六进制字符串实例化颜色

 @param hexString 十六进制字符串
 @return 颜色值
*/
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
