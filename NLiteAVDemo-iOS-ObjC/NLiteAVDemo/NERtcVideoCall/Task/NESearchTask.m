//
//  NESearchTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NESearchTask.h"

@implementation NESearchTask
+ (instancetype)task {
    return [self taskWithSubURL:@"/p2pVideoCall/caller/searchSubscriber"];
}

@end
