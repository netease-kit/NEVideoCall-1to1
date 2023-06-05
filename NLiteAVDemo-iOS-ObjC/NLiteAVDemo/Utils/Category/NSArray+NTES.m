// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSArray+NTES.h"

@implementation NSArray (NTES)

- (void)writeToFile:(NSString *)fileName {
  NSString *path =
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *filePath =
      [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
  [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (NSArray *)readArchiveFile:(NSString *)fileName {
  NSString *path =
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *filePath =
      [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
  NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
  return array;
}
@end
