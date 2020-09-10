//
//  NELoginOptions.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NELoginBlock)(void);

@interface NELoginOptions : NSObject

@property (nonatomic, copy) NELoginBlock successBlock;  // 登录成功闭包
@property (nonatomic, copy) NELoginBlock failedBlock;   // 登录失败闭包
@property (nonatomic, copy) NELoginBlock cancelBlock;   // 取消登录闭包

@end

NS_ASSUME_NONNULL_END
