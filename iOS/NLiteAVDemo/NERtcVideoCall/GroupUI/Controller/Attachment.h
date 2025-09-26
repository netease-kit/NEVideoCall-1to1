// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

@interface Attachment : NSObject <NIMCustomAttachment>
// 商品名
@property(nonatomic, copy) NSString *goodsName;
// 商品链接
@property(nonatomic, copy) NSString *goodsURL;
@end
