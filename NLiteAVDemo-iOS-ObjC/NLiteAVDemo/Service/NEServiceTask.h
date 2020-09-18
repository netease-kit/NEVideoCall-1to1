//
//  NEServiceTask.h
//  NEDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NEServiceTask <NSObject>

- (NSURLRequest *)taskRequest;

@end

NS_ASSUME_NONNULL_END
