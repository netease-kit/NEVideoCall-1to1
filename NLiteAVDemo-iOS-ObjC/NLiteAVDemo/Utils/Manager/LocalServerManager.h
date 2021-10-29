//
//  LocalServerManager.h
//  NLiteAVDemo
//
//  Created by yu chen on 2021/10/27.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalServerManager : NSObject

+ (id)shareInstance;

- (void)startServer;

@end

NS_ASSUME_NONNULL_END
