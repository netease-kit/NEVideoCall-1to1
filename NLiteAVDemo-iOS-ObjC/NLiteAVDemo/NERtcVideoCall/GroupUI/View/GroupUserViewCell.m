// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "GroupUserViewCell.h"

@interface GroupUserViewCell ()

@property(nonatomic, strong) UIImageView *userHeader;

@end

@implementation GroupUserViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.userHeader = [[UIImageView alloc] init];
  [self addSubview:self.userHeader];
  self.userHeader.clipsToBounds = YES;
  self.userHeader.layer.cornerRadius = 2.0;
  [self.userHeader mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.width.height.mas_equalTo(self);
  }];
}

- (void)configureWithUser:(NEUser *)user {
  [self.userHeader sd_setImageWithURL:[NSURL URLWithString:user.avatar]];
}

@end
