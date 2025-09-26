// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <objc/runtime.h>
#import "NEGroupUser+Private.h"

@implementation NEGroupUser (Private)

- (NSInteger)originalIndex {
  NSNumber *value = objc_getAssociatedObject(self, @selector(originalIndex));
  return value ? [value integerValue] : 0;
}

- (void)setOriginalIndex:(NSInteger)originalIndex {
  objc_setAssociatedObject(self, @selector(originalIndex), @(originalIndex),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
