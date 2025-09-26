// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NECallStatusRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallStatusRecordCell : UITableViewCell

- (void)configure:(NECallStatusRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
