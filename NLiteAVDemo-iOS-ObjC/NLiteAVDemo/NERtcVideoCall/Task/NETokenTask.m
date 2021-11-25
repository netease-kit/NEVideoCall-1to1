//
//  NETokenTask.m
//  NLiteAVDemo
//
//  Created by chenyu on 2021/9/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETokenTask.h"

@implementation NETokenTask

+ (instancetype)taskWithUid:(NSString *)uid withAppkey:(NSString *)appkey {
    return [self taskWithURLString:[NSString stringWithFormat:@"http://nrtc.netease.im/demo/getChecksum.action?uid=%@&appkey=%@",uid,appkey]];
}

- (NSURLRequest *)taskRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.getURL]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    return request;
}

@end
