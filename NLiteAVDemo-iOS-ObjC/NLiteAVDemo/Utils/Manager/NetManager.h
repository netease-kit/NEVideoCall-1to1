//
//  NetManager.h
//  NLiteAVDemo
//
//  Created by yu chen on 2021/10/21.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetManager : NSObject

@property(nonatomic, assign) BOOL isClose;

+ (id)shareInstance;

@end

NS_ASSUME_NONNULL_END
