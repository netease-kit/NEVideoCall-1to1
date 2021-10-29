//
//  NSArray+NTES.h
//  NLiteAVDemo
//
//  Created by yu chen on 2021/10/19.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (NTES)

- (void)writeToFile:(NSString *)fileName;

+ (NSArray *)readArchiveFile:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
