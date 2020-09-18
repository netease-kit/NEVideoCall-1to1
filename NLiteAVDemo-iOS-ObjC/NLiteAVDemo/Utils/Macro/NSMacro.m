//
//  NSMacro.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NSMacro.h"

void ntes_main_sync_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void ntes_main_async_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
