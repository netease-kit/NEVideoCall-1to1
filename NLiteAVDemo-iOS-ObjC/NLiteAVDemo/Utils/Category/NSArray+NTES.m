//
//  NSArray+NTES.m
//  NLiteAVDemo
//
//  Created by yu chen on 2021/10/19.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NSArray+NTES.h"

@implementation NSArray (NTES)

- (void)writeToFile:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (NSArray *)readArchiveFile:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return array;
}
@end
