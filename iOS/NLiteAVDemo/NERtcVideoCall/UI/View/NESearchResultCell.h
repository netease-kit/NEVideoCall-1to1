// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SearchCellDelegate <NSObject>

- (void)didSelectSearchUser:(NEUser *)user;

@end

@interface NESearchResultCell : UITableViewCell

@property(nonatomic, weak) id<SearchCellDelegate> delegate;

- (void)configureUI:(NEUser *)user;

- (void)setGrayBtn;
- (void)setBlueBtn;
- (void)setConectting;

@end

NS_ASSUME_NONNULL_END
