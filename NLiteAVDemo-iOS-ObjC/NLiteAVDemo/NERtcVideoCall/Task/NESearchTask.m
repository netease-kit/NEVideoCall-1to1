// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NESearchTask.h"

@implementation NESearchTask
+ (instancetype)task {
  return [self taskWithSubURL:@"/p2pVideoCall/caller/searchSubscriber"];
}

@end
