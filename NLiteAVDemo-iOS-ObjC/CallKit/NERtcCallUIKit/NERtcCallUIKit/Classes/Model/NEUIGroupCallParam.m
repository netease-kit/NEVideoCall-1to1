// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIGroupCallParam.h"

@implementation NEUIGroupCallParam

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setupDefaultValues];
  }
  return self;
}

#pragma mark - 私有方法

- (void)setupDefaultValues {
  // 设置默认值
  self.remoteUsers = @[];
}

@end
