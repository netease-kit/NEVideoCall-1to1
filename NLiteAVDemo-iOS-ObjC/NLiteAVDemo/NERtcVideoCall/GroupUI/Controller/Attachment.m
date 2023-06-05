// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "Attachment.h"
@implementation Attachment

// 实现 NIMCustomAttachment 的 encodeAttachment 方法
- (NSString *)encodeAttachment {
  // 商品信息内容以字典封装
  NSDictionary *dict = @{
    @"goodsName" : self.goodsName,
    @"goodsURL" : self.goodsURL,
  };

  // 进一步序列化得到 content 并返回
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  NSString *content = nil;

  if (jsonData) {
    content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }

  return content;
}
@end
